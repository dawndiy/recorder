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
import Ubuntu.Components.Popups 1.3
import "../component"

Page {
    id: settingsPage

    function resetSettings() {
        settings.audioCodec = "default"
        settings.fileContainer = "default"
        settings.channels = 1
        settings.encodingMode = -1
        settings.encodingQuality = -1
        settings.bitrate = -1
        settings.disableScreenSaver = true
        settings.showSoundWave = true
        settings.microphoneVolume = 90

        screenSaverSwitch.checked = settings.disableScreenSaver
        soundWaveSwitch.checked = settings.showSoundWave
        vSlider.value = settings.microphoneVolume
    }

    header: generalHeader
    state: "general"

    PageHeader {
        id: generalHeader
        z: 1
        opacity: 1
        visible: settingsPage.header === generalHeader
        // TRANSLATORS: The title of settings page
        title: i18n.tr("Settings")

        leadingActionBar.delegate: HeaderButton {}
        trailingActionBar.delegate: HeaderButton {}
        leadingActionBar.actions: Action {
            iconName: "back"
            onTriggered: {
                // settingsPage.pageStack.removePages(settingsPage)
                pageLayout.removePage(settingsPage)
            }
        }
        trailingActionBar.actions: [
            Action {
                iconName: "view-expand"
                // TRANSLATORS: The title of advanced settings page
                text: i18n.tr("Advanced Settings")
                onTriggered: {
                    settingsPage.state = "advanced"
                }
            },
            Action {
                iconName: "reset"
                text: i18n.tr("Reset")
                onTriggered: {
                    var popup = PopupUtils.open(dialog)
                    popup.accepted.connect(function() {
                        resetSettings()
                        popup.destroy();
                        notification(i18n.tr("All settings have been reset."))
                    })
                }
            }

        ]

        StyleHints {
            foregroundColor: "#FFF"
            backgroundColor: "#85D8CE"
            dividerColor: "#85D8CE"
        }
    }

    PageHeader {
        id: advancedHeader
        z: 1
        opacity: 1
        visible: settingsPage.header === advancedHeader
        title: i18n.tr("Advanced Settings")

        leadingActionBar.delegate: HeaderButton {}
        trailingActionBar.delegate: HeaderButton {}
        leadingActionBar.actions: Action {
            iconName: "back"
            onTriggered: {
                // settingsPage.pageStack.removePages(settingsPage)
                pageLayout.removePage(settingsPage)
            }
        }
        trailingActionBar.actions: [
            Action {
                iconName: "view-collapse"
                text: i18n.tr("General Settings")
                onTriggered: {
                    settingsPage.state = "general"
                }
            },
            Action {
                iconName: "reset"
                text: i18n.tr("Reset")
                onTriggered: {
                    var popup = PopupUtils.open(dialog)
                    popup.accepted.connect(function() {
                        resetSettings()
                        popup.destroy();
                        notification(i18n.tr("All settings have been reset."))
                    })
                }
            }
        ]

        StyleHints {
            foregroundColor: "#FFF"
            backgroundColor: "#85D8CE"
            dividerColor: "#85D8CE"
        }
    }

    Flickable {
        anchors {
            top: parent.header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        contentHeight: column.height

        Column {
            id: column
            anchors.fill: parent

            ListItem {
                height: screenLayout.height + (divider.visible ? divider.height : 0)
                ListItemLayout {
                    id: screenLayout
                    title.text: i18n.tr("Keep screen on")
                    title.color: "white"

                    Switch {
                        id: screenSaverSwitch
                        checked: settings.disableScreenSaver
                        onCheckedChanged: {
                            settings.disableScreenSaver = checked
                        }
                    }
                }
            }

            ListItem {
                height: waveLayout.height + (divider.visible ? divider.height : 0)
                ListItemLayout {
                    id: waveLayout
                    title.text: i18n.tr("Show sound wave")
                    title.color: "white"

                    Switch {
                        id: soundWaveSwitch
                        checked: settings.showSoundWave
                        onCheckedChanged: {
                            settings.showSoundWave = checked
                        }
                    }
                }
            }

            ListItem {
                height: volumeLayout.height + vSlider.height + (divider.visible ? divider.height : 0)
                ListItemLayout {
                    id: volumeLayout
                    title.text: i18n.tr("Microphone volume")
                    title.color: "white"
                }

                Icon {
                    id: vIcon
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(2)
                        verticalCenter: vSlider.verticalCenter
                    }
                    height: vSlider.height / 2
                    width: height
                    name: vSlider.value !== 0 ? "audio-input-microphone-symbolic" :
                                                "audio-input-microphone-muted-symbolic"
                    color: "white"
                }

                Slider {
                    id: vSlider
                    anchors {
                        left: vIcon.right
                        leftMargin: units.gu(3)
                        right: parent.right
                        rightMargin: units.gu(3)
                        bottom: parent.bottom
                    }
                    minimumValue: 0
                    maximumValue: 100
                    stepSize: 1
                    value: settings.microphoneVolume
                    onValueChanged: {
                        settings.microphoneVolume = formatValue(value)
                    }

                    StyleHints {
                        foregroundColor: "#85D8CE"
                        backgroundColor: "#085078"
                    }
                }
            }

            // General Settings

            ListItem {
                visible: settingsPage.state === "general"
                height: visible ? gQualityLayout.height + (divider.visible ? divider.height : 0) : 0
                highlightColor: "#246588"

                onClicked: {
                    pageLayout.addPageToCurrentColumn(
                                settingsPage,
                                Qt.resolvedUrl("SelectionPage.qml"),
                                {
                                    title: i18n.tr("Record Quality"),
                                    listData: recorder.qualityList,
                                    state: "recordQuality"
                                })
                }

                ListItemLayout {
                    id: gQualityLayout
                    title.text: i18n.tr("Record Quality")
                    title.color: "white"

                    ProgressionSlot { color: "white" }

                    Label {
                        text: settings.encodingQuality === -1 ? i18n.tr("default") : recorder.qualityList[settings.encodingQuality]
                        color: UbuntuColors.porcelain
                    }
                }

            }

            // Advanced Settings

            ListItem {
                visible: settingsPage.state === "advanced"
                height: visible ? codecLayout.height + (divider.visible ? divider.height : 0) : 0
                highlightColor: "#246588"

                onClicked: {
                    pageLayout.addPageToCurrentColumn(
                                settingsPage,
                                Qt.resolvedUrl("SelectionPage.qml"),
                                {
                                    title: i18n.tr("Audio Codec"),
                                    listData: recorder.supportedAudioCodecs(),
                                    state: "codec"
                                })
                }

                ListItemLayout {
                    id: codecLayout

                    title.text: i18n.tr("Audio Codec")
                    title.color: "white"

                    ProgressionSlot { color: "white" }

                    Label {
                        text: settings.audioCodec === "default" ? i18n.tr("default") : settings.audioCodec
                        color: UbuntuColors.porcelain
                    }
                }
            }

            ListItem {
                visible: settingsPage.state === "advanced"
                height: visible ? containerLayout.height + (divider.visible ? divider.height : 0) : 0
                highlightColor: "#246588"

                onClicked: {
                    pageLayout.addPageToCurrentColumn(
                                settingsPage,
                                Qt.resolvedUrl("SelectionPage.qml"),
                                {
                                    title: i18n.tr("File Container"),
                                    listData: recorder.supportedContainers(),
                                    state: "container"
                                })
                }

                ListItemLayout {
                    id: containerLayout

                    title.text: i18n.tr("File Container")
                    title.color: "white"

                    ProgressionSlot { color: "white" }

                    Label {
                        text: settings.fileContainer === "default" ? i18n.tr("default") : settings.fileContainer
                        color: UbuntuColors.porcelain
                    }
                }
            }

            ListItem {
                visible: settingsPage.state === "advanced" && settings.audioCodec !== "audio/vorbis" && settings.audioCodec !== "default"
                height: visible ? channelLayout.height + (divider.visible ? divider.height : 0) : 0
                highlightColor: "#246588"

                onClicked: {
                    pageLayout.addPageToCurrentColumn(
                                settingsPage,
                                Qt.resolvedUrl("SelectionPage.qml"),
                                {
                                    title: i18n.tr("Channels"),
                                    listData: recorder.channelList,
                                    state: "channel"
                                })
                }

                ListItemLayout {
                    id: channelLayout

                    // TRANSLATORS: The count of sound channel
                    title.text: i18n.tr("Channels")
                    title.color: "white"

                    ProgressionSlot { color: "white" }

                    Label {
                        text: settings.channels
                        color: UbuntuColors.porcelain
                    }
                }
            }

            ListItem {
                id: encodingModeItem

                visible: settingsPage.state === "advanced"
                height: visible ? modeLayout.height + (divider.visible ? divider.height : 0) : 0
                highlightColor: "#246588"

                onClicked: {
                    pageLayout.addPageToCurrentColumn(
                                settingsPage,
                                Qt.resolvedUrl("SelectionPage.qml"),
                                {
                                    title: i18n.tr("Encoding Mode"),
                                    listData: recorder.encodingModeList,
                                    state: "encodingMode"
                                })
                }

                ListItemLayout {
                    id: modeLayout

                    title.text: i18n.tr("Encoding Mode")
                    title.color: "white"

                    ProgressionSlot { color: "white" }

                    Label {
                        text: settings.encodingMode === -1 ? i18n.tr("default") : recorder.encodingModeList[settings.encodingMode]
                        color: UbuntuColors.porcelain
                    }
                }
            }

            ListItem {
                id: encodingQualityItem

                visible: settingsPage.state === "advanced" && settings.encodingMode !== 1
                height: visible ? qualityLayout.height + (divider.visible ? divider.height : 0) : 0
                highlightColor: "#246588"

                onClicked: {
                    pageLayout.addPageToCurrentColumn(
                                settingsPage,
                                Qt.resolvedUrl("SelectionPage.qml"),
                                {
                                    title: i18n.tr("Encoding Quality"),
                                    listData: recorder.qualityList,
                                    state: "encodingQuality"
                                })
                }

                ListItemLayout {
                    id: qualityLayout

                    title.text: i18n.tr("Encoding Quality")
                    title.color: "white"

                    ProgressionSlot { color: "white" }

                    Label {
                        text: settings.encodingQuality === -1 ? i18n.tr("default") : recorder.qualityList[settings.encodingQuality]
                        color: UbuntuColors.porcelain
                    }
                }
            }

            ListItem {
                id: bitrateItem

                visible: settingsPage.state === "advanced" && settings.encodingMode === 1
                height: visible ? bitrateLayout.height + (divider.visible ? divider.height : 0) : 0
                highlightColor: "#246588"

                onClicked: {
                    pageLayout.addPageToCurrentColumn(
                                settingsPage,
                                Qt.resolvedUrl("SelectionPage.qml"),
                                {
                                    title: i18n.tr("Bitrate"),
                                    listData: recorder.bitrateList,
                                    state: "bitrate"
                                })
                }

                ListItemLayout {
                    id: bitrateLayout

                    title.text: i18n.tr("Bitrate")
                    title.color: "white"

                    ProgressionSlot { color: "white" }

                    Label {
                        text: settings.bitrate === -1 ? i18n.tr("default") : recorder.bitrateList[settings.bitrate]
                        color: UbuntuColors.porcelain
                    }
                }
            }
        }
    }

    Component {
        id: dialog

        Dialog {
            id: dialogue

            signal accepted

            title: i18n.tr("Reset")
            text: i18n.tr("Do you want reset settings?")


            Button {
                text: i18n.tr("Reset")
                color: UbuntuColors.green
                onClicked: accepted()
            }

            Button {
                text: i18n.tr("Cancel")
                onClicked: PopupUtils.close(dialogue)
            }

        }
    }

    states: [
        State {
            name: "general"
            PropertyChanges {
                target: settingsPage
                header: generalHeader

            }
        },
        State {
            name: "advanced"
            PropertyChanges {
                target: settingsPage
                header: advancedHeader
            }
        }

    ]
}
