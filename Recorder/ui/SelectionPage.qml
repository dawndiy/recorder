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
import Ubuntu.Components 1.3
import "../component"

Page {
    id: selectionPage

    property alias title: pageHeader.title
    property var listData: []
    property var selectFunc: null
    property var selectedValue: null

    function selectCodec(index, data) {
        settings.audioCodec = data
        if (data === "audio/x-vorbis") {
            settings.channels = 1
        }
    }

    function selectContainer(index, data) {
        settings.fileContainer = data
    }

    function selectChannel(index, data) {
        settings.channels = Number(data)
    }

    function selectEncodingMode(index, data) {
        settings.encodingMode = Number(index)
    }

    function selectEncodingQuality(index, data) {
        settings.encodingQuality = Number(index)
    }

    function selectBitrate(index, data) {
        settings.bitrate = Number(index)
    }

    function selectRecordQuality(index, data) {
        settings.encodingQuality = Number(index)
        settings.encodingMode = 0
        settings.channels = 1
        settings.fileContainer = "default"
        settings.audioCodec = "default"
    }


    header: PageHeader {
        id: pageHeader

        leadingActionBar.delegate: HeaderButton {}
        trailingActionBar.delegate: HeaderButton {}
        StyleHints {
            foregroundColor: "#FFF"
            backgroundColor: "#85D8CE"
            dividerColor: "#85D8CE"
        }
    }

    ListView {
        id: listView

        anchors {
            top: parent.header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        model: listData

        delegate: ListItem {
            height: layout.height + (divider.visible ? divider.height : 0)
            highlightColor: "#246588"

            onClicked: {
                if (selectFunc) {
                    selectFunc(index, modelData.value)
                }
                // selectionPage.pageStack.removePages(selectionPage)
                pageLayout.removePage(selectionPage)
            }

            ListItemLayout {
                id: layout
                title.text: modelData.name
                title.color: "white"

                Icon {
                    name: "ok"
                    height: units.gu(2)
                    width: height
                    color: "white"
                    visible: selectedValue == modelData.value
                }
            }
        }
    }

    states: [
        State {
            name: "codec"
            PropertyChanges {
                target: selectionPage
                selectFunc: selectCodec
            }
        },
        State {
            name: "container"
            PropertyChanges {
                target: selectionPage
                selectFunc: selectContainer
            }
        },
        State {
            name: "channel"
            PropertyChanges {
                target: selectionPage
                selectFunc: selectChannel
            }
        },
        State {
            name: "encodingMode"
            PropertyChanges {
                target: selectionPage
                selectFunc: selectEncodingMode
            }
        },
        State {
            name: "encodingQuality"
            PropertyChanges {
                target: selectionPage
                selectFunc: selectEncodingQuality

            }
        },
        State {
            name: "bitrate"
            PropertyChanges {
                target: selectionPage
                selectFunc: selectBitrate
            }
        },
        State {
            name: "recordQuality"
            PropertyChanges {
                target: selectionPage
                selectFunc: selectRecordQuality
            }
        }

    ]
}
