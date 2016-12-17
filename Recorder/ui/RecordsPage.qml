/*
 * Copyright (C) 2016  DawnDIY <dawndiy.dev@gmail.com>
 *
 * This file is part of Recorder
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import QtMultimedia 5.5
import Qt.labs.folderlistmodel 2.1
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3
import Ubuntu.Components.Popups 1.3
import "../component"

Page {
    id: recordsPage

    property var transfer: null
    property var exportFileInfos: []

    function formatSize(size) {
        var result;
        if ((size / 1024) < 1024) {
            result = (size / 1024).toFixed(2) + " KB"
        } else {
            result = (size / (1024*1024)).toFixed(2) + " MB"
        }
        return result
    }

    function exportFile() {
        var result = []
        for (var i = 0; i < recordsPage.exportFileInfos.length; i++) {
            var file_info = recordsPage.exportFileInfos[i]
            var file_url = file_info.url
            var file_name = file_info.name
            var item = exportItem.createObject(recordsPage, { "url": Qt.resolvedUrl(file_url), "text": file_name })
            result.push(item)
        }
        if (result.length > 0 && transfer) {
            transfer.items = result
            transfer.state = ContentTransfer.Charged
            // recordsPage.pageStack.removePages(recordsPage)
            pageLayout.removePage(recordsPage)
        }
    }

    header: standardHeader
    state: "standard"

    PageHeader {
        id: standardHeader
        title: recordsPage.state === "standard" ?
                   // TRANSLATORS: Title of record list page
                   i18n.tr("Records") :
                   // TRANSLATORS: Title of the export files page
                   i18n.tr("Export Records")
        visible: recordsPage.header === standardHeader
        opacity: 1

        leadingActionBar.delegate: HeaderButton {}
        trailingActionBar.delegate: HeaderButton {}

        leadingActionBar.actions: [
            Action {
                iconName: "back"
                // TRANSLATORS: Go back previous page
                text: i18n.tr("Back")
                // onTriggered: recordsPage.pageStack.removePages(recordsPage)
                onTriggered: pageLayout.removePage(recordsPage)
                visible: recordsPage.state === "standard"
            },
            Action {
                iconName: "close"
                // TRANSLATORS: Close export file page
                text: i18n.tr("Close")
                visible: recordsPage.state === "exporter"
                onTriggered: {
                    if (transfer) {
                        transfer.state = ContentTransfer.Aborted
                    }
                    // recordsPage.pageStack.removePages(recordsPage)
                    pageLayout.removePage(recordsPage)
                }
            }

        ]

        trailingActionBar.actions: [
            Action {
                iconName: "search"
                text: i18n.tr("Search")
                onTriggered: recordsPage.header = searchHeader
            },
            Action {
                iconSource: "../image/sorting.svg"
                text: i18n.tr("Sorting")
                onTriggered: {
                    var popup = PopupUtils.open(
                                dialogSorting, recordsPage,
                                {sortOrder: settings.recordsSorting})
                    popup.accepted.connect( function(sortOrder) {
                        settings.recordsSorting = sortOrder
                        folderModel.setSortField(sortOrder)
                        popup.destroy();
                    })
                }
            },
            Action {
                iconName: "tick"
                // TRANSLATORS: OK to comfirm export files.
                text: i18n.tr("OK")
                onTriggered: exportFile()
                visible: recordsPage.state === "exporter"
            }

        ]

        StyleHints {
            foregroundColor: "#FFF"
            backgroundColor: "#85D8CE"
            dividerColor: "#85D8CE"
        }
    }

    PageHeader {
        id: searchHeader
        visible: recordsPage.header === searchHeader

        leadingActionBar.delegate: HeaderButton {}
        trailingActionBar.delegate: HeaderButton {}
        leadingActionBar.actions: [
            Action {
                iconName: "back"
                text: i18n.tr("Back")
                onTriggered: recordsPage.header = standardHeader
            }
        ]
        contents: TextField {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            opacity: 0.6
            placeholderText: i18n.tr("Search...")
            onTextChanged: {
                folderModel.setFilter(text)
            }
        }

        StyleHints {
            foregroundColor: "#FFF"
            backgroundColor: "#85D8CE"
            dividerColor: "#85D8CE"
        }
    }

    FolderListModel {
        id: folderModel

        function setFilter(key) {
            var defaultFilters = [
                "*.mkv",
                "*.ogg",
                "*.wav",
                "*.avi",
                "*.3gp",
                "*.flv",
                "*.raw"
            ];
            if (key) {
                for (var i = 0; i < defaultFilters.length; i++) {
                    var f = defaultFilters[i]
                    var t = f.replace(/\*/g, "*" + key + "*")
                    defaultFilters[i] = t
                }
            }
            nameFilters = defaultFilters
        }

        function setSortField(index) {
            var fields = [
                        [FolderListModel.Unsorted, false],
                        [FolderListModel.Name, false],
                        [FolderListModel.Name, true],
                        [FolderListModel.Time, false],
                        [FolderListModel.Time, true],
                        [FolderListModel.Size, true],
                        [FolderListModel.Size, false]
                    ]
            sortField = fields[index][0]
            sortReversed = fields[index][1]
        }

        folder: "file://" + recorder.filePath
        showDirs: false

        Component.onCompleted: {
            setFilter()
            setSortField(settings.recordsSorting)
        }
    }

    Item {
        id: emptyTips
        visible: folderModel.count == 0
        width: parent.width / 2
        height: width
        anchors.centerIn: parent

        Icon {
            id: emptyIcon
            name: "note"
            width: units.gu(5)
            height: width
            anchors.centerIn: parent
            color: UbuntuColors.porcelain
        }

        Label {
            anchors.top: emptyIcon.bottom
            anchors.topMargin: units.gu(2)
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n.tr("No records")
            textSize: Label.Large
            color: UbuntuColors.porcelain
        }
    }

    ListView {
        id: fileList

        anchors {
            top: parent.header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        model: folderModel

        delegate: ListItem {
            id: listItem
            height: layout.height + (divider.visible ? divider.height : 0)
            leadingActions: ListItemActions {
                actions: [
                    Action {
                        iconName: "delete"
                        // TRANSLATORS: An action name for delete a record file.
                        name: i18n.tr("Delete")
                        visible: recordsPage.state === "standard"
                        onTriggered: {
                            var popup = PopupUtils.open(
                                        dialogDelete, recordsPage,
                                        { fileName: fileName })
                            popup.accepted.connect(function() {
                                recorder.deleteRecordFile(filePath)
                                popup.destroy()
                                notification(i18n.tr("%1 has been deleted.").arg(fileName))
                            })
                        }
                    }
                ]
            }
            trailingActions: ListItemActions {
                actions: [
                    Action {
                        iconName: "edit"
                        // TRANSLATORS: An action name for rename the file name.
                        name: i18n.tr("Rename")
                        visible: recordsPage.state === "standard"
                        onTriggered: {
                            PopupUtils.open(dialogRename, null,
                                            {
                                                'fileName': fileBaseName,
                                                'filePath': filePath,
                                                'fileSuffix': fileSuffix
                                            })
                        }
                    },
                    Action {
                        iconName: "info"
                        // TRANSLATORS: An action name for the record file info.
                        name: i18n.tr("Info")
                        onTriggered: {
                            PopupUtils.open(dialogInfo, null, { 'fileIndex': index })
                        }
                    }

                ]
            }
            highlightColor: "#246588"

            onClicked: {
                player.source = Qt.resolvedUrl(fileURL)
                if (player.playbackState === MediaPlayer.StoppedState) {
                    player.play()
                } else {
                    player.stop()
                }
            }

            ListItemLayout {
                id: layout

                title.text: fileBaseName
                title.color: "white"
                subtitle.text: formatSize(fileSize)
                subtitle.color: UbuntuColors.porcelain

                CheckBox {
                    SlotsLayout.position: SlotsLayout.Leading
                    SlotsLayout.overrideVerticalPositioning: true
                    anchors.verticalCenter: parent.verticalCenter
                    visible: recordsPage.state === "exporter"
                    onCheckedChanged: {
                        var info = { url: fileURL, name: fileName }
                        if (checked) {
                            recordsPage.exportFileInfos.push(info)
                        } else {
                            var i = recordsPage.exportFileInfos.indexOf(info)
                            if (i !== -1) {
                                recordsPage.exportFileInfos.splice(i, 1)
                            }
                        }
                    }
                }

                Text {
                    id: recordPlayTime
                    function setTime(time) {
                        var time_str
                        var record_time = Math.ceil(time/1000)
                        var sec = record_time % 60
                        var min = Math.floor(record_time / 60) % 60
                        var hr = Math.floor(record_time / 3600)
                        if (hr > 0) {
                            time_str = hr + ":"
                            time_str += new Array(2-String(min).length+1).join("0") + min + ":"
                            time_str += new Array(2-String(sec).length+1).join("0") + sec
                        } else {
                            time_str = new Array(2-String(min).length+1).join("0") + min + ":"
                            time_str += new Array(2-String(sec).length+1).join("0") + sec
                        }
                        text = time_str
                    }
                    SlotsLayout.overrideVerticalPositioning: true
                    anchors.verticalCenter: parent.verticalCenter
                    text: "00:00"
                    color: UbuntuColors.porcelain
                    visible: player.source === fileURL && player.playbackState !== MediaPlayer.StoppedState

                }

                Icon {
                    SlotsLayout.overrideVerticalPositioning: true
                    anchors.verticalCenter: parent.verticalCenter
                    height: units.gu(3.5)
                    name: player.playbackState === MediaPlayer.PlayingState ? "media-preview-pause" : "media-preview-start"
                    color: UbuntuColors.porcelain
                    visible: player.source === fileURL && player.playbackState !== MediaPlayer.StoppedState

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (parent.visible) {
                                Haptics.play()
                                if (player.playbackState === MediaPlayer.PlayingState) {
                                    player.pause()
                                } else {
                                    player.play()
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: recordPlayPosition
                height: units.gu(0.2)
                width: 0
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                }
                visible: player.source === fileURL && player.playbackState !== MediaPlayer.StoppedState
                color: "#085078"

                Behavior on width {
                    NumberAnimation { duration: 1000; easing.type: Easing.Linear }
                }
            }

            Connections {
                target: player
                onPositionChanged: {
                    if (player.source === fileURL) {
                        recordPlayTime.setTime(
                                    player.duration - player.position)
                        recordPlayPosition.width = player.position * parent.width / player.duration
                    }
                }
            }
        }

        visible: folderModel.count == 0 ? false : true
    }

    Component {
        id: dialogInfo
        Dialog {
            id: dialogueInfo
            property int fileIndex: 0

            title: i18n.tr("Record Information")

            Label {
                wrapMode: Text.WordWrap
                text: i18n.tr("<b>Name</b>: %1").arg(folderModel.get(fileIndex, "fileBaseName"))
            }

            Label {
                text: i18n.tr("<b>Type</b>: %1").arg(folderModel.get(fileIndex, "fileSuffix"))
            }

            Label {
                text: i18n.tr("<b>Size</b>: %1 (%2 B)").arg(formatSize(folderModel.get(fileIndex, "fileSize"))).arg(folderModel.get(fileIndex, "fileSize"))
            }

            Label {
                wrapMode: Text.WrapAnywhere
                // TRANSLATORS: The location where the record file is stored.
                text: i18n.tr("<b>Location</b>: %1").arg(folderModel.get(fileIndex, "filePath"))
            }

            Label {
                wrapMode: Text.WordWrap
                // TRANSLATORS: The last accessed time.
                text: i18n.tr("<b>Accessed</b>: %1").arg(folderModel.get(fileIndex, "fileAccessed"))
            }

            Label {
                wrapMode: Text.WordWrap
                // TRANSLATORS: The last modified time.
                text: i18n.tr("<b>Modified</b>: %1").arg(folderModel.get(fileIndex, "fileModified"))
            }

            Button {
                text: i18n.tr("Close")
                onClicked: PopupUtils.close(dialogueInfo)
            }
        }
    }

    Component {
        id: dialogRename
        Dialog {
            id: dialogueRename

            property string filePath: null
            property string fileName: ""
            property string fileSuffix: null

            function renameFile() {
                if (filePath && fileSuffix &&
                        fileNameTextField.text.length > 0) {
                    var name = fileNameTextField.text + "." + fileSuffix
                    recorder.renameRecordFile(filePath, name)
                }
            }

            title: i18n.tr("Rename Record File")
            text: i18n.tr("Please enter a new file name.")

            TextField {
                id: fileNameTextField
                text: fileName
            }

            Button {
                text: i18n.tr("Save")
                color: UbuntuColors.green
                onClicked: {
                    renameFile()
                    PopupUtils.close(dialogueRename)
                }
            }

            Button {
                text: i18n.tr("Cancel")
                onClicked: PopupUtils.close(dialogueRename)
            }
        }
    }

    Component {
        id: dialogSorting
        Dialog {
            id: dialogueSorting
            title: i18n.tr("Sort by")

            property alias sortOrder: optionSelector.selectedIndex

            signal accepted(int sortOrder);

            OptionSelector {
                id: optionSelector
                expanded: true
                model: [
                    i18n.tr("Unsorted (default)"),
                    i18n.tr("File name (ascending)"),
                    i18n.tr("File name (descending)"),
                    i18n.tr("Time modified (newest first)"),
                    i18n.tr("Time modified (oldest first)"),
                    i18n.tr("Size (ascending)"),
                    i18n.tr("Size (descending)")
                ]
                delegate: OptionSelectorDelegate {
                    objectName: "sortingOption" + index
                }
                onDelegateClicked: {
                    dialogueSorting.accepted(index);
                    PopupUtils.close(dialogueSorting);
                }
            }
        }
    }

    Component {
        id: dialogDelete
        Dialog {
            id: dialogueDelete

            property string fileName: ""

            signal accepted

            title: i18n.tr("Delete")
            text: i18n.tr("Do you want delete %1 ?").arg(fileName)

            Button {
                text: i18n.tr("Delete")
                color: UbuntuColors.red
                onClicked: accepted()
            }

            Button {
                text: i18n.tr("Cancel")
                onClicked: PopupUtils.close(dialogueDelete)
            }
        }
    }

    Component {
        id: exportItem
        ContentItem {}
    }

    states: [
        State {
            name: "standard"
        },
        State {
            name: "exporter"
        }

    ]
}
