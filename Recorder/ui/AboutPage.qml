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
import QtGraphicalEffects 1.0
import Ubuntu.Components 1.3
import "../component"

Page {
    id: aboutPage

    header: PageHeader {
        // TRANSLATORS: Title of About page.
        title: i18n.tr("About")
        opacity: 1

        leadingActionBar.delegate: HeaderButton {}
        trailingActionBar.delegate: HeaderButton {}

        leadingActionBar.actions: Action {
            iconName: "back"
            onTriggered: {
                pageLayout.removePage(aboutPage)
            }
        }

        extension: Sections {
            id: sections
            anchors {
                horizontalCenter: parent.horizontalCenter
            }

            model: [
                // TRANSLATORS: A section name of top Sections.
                i18n.tr("About"),
                // TRANSLATORS: A section name of top Sections.
                i18n.tr("Support")
            ]

            onSelectedIndexChanged: tabView.currentIndex = selectedIndex

            StyleHints {
                sectionColor: "#88FFFFFF"
                selectedSectionColor: "White"
                underlineColor: "Transparent"
                pressedBackgroundColor: "#76C8C4"
            }
        }

        StyleHints {
            foregroundColor: "#FFF"
            backgroundColor: "#85D8CE"
            dividerColor: "#85D8CE"
        }
    }

    VisualItemModel {
        id: tabs

        Item {
            width: tabView.width
            height: tabView.height
            opacity: tabView.currentIndex === 0 ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.InOutCubic }
            }

            Flickable {
                anchors.fill: parent
                contentHeight: layout.height

                Column {
                    id: layout

                    spacing: units.gu(3)
                    anchors {
                        top: parent.top
                        topMargin: units.gu(5)
                        left: parent.left
                        right: parent.right
                    }

                    Image {
                        id: logoImage
                        height: width
                        width: Math.min(parent.width/2, parent.height/2)
                        source: Qt.resolvedUrl("../Recorder.png")
                        // sourceSize.width: units.gu(20)
                        // sourceSize.height: units.gu(20)
                        anchors.horizontalCenter: parent.horizontalCenter
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Item {
                                width: logoImage.width
                                height: logoImage.height
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: Math.min(logoImage.width, logoImage.height)
                                    height: width
                                    radius: Math.min(height, width)
                                }
                            }
                        }
                    }

                    Column {
                        width: parent.width

                        Label {
                            width: parent.width
                            textSize: Label.XLarge
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignHCenter
                            // TRANSLATORS: Recorder is the name of this App.
                            text: i18n.tr("Recorder")
                            color: "white"
                        }
                        Label {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            // TRANSLATORS: Recorder version number e.g Version 1.0.0
                            text: i18n.tr("Version %1").arg(root.appVersion)
                            color: UbuntuColors.porcelain
                        }
                    }

                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        // TRANSLATORS: The summary of this App.
                        text: i18n.tr("Audio Recorder for Ubuntu.")
                        color: UbuntuColors.porcelain
                    }

                    Column {
                        anchors {
                            left: parent.left
                            right: parent.right
                            margins: units.gu(2)
                        }

                        Label {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            text: "(C) 2016 DawnDIY"
                            color: UbuntuColors.porcelain
                        }

                        Label {
                            textSize: Label.Small
                            width: parent.width
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            // TRANSLATORS: release license
                            text: i18n.tr("Released under the terms of the <a href=\"https://github.com/dawndiy/recorder/blob/master/LICENSE\">GNU GPL v3</a>")
                            onLinkActivated: Qt.openUrlExternally(link)
                            linkColor: "#85D8CE"
                            color: UbuntuColors.porcelain
                        }

                    }

                    Button {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: i18n.tr("Donate")
                        color: UbuntuColors.green
                        onClicked: {
                            pageStack.addPageToCurrentColumn(
                                        aboutPage,
                                        Qt.resolvedUrl("DonatePage.qml"))
                        }
                    }

                    Item {
                        width: parent.width
                        height: units.gu(5)
                    }
                }
            }
        }

        Item {
            width: tabView.width
            height: tabView.height
            opacity: tabView.currentIndex === 1 ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.InOutCubic }
            }

            ListModel {
                id: creditsModel
                Component.onCompleted: initialize()

                function initialize() {
                    // Resources
                    creditsModel.append({ category: i18n.tr("Resources"), name: i18n.tr("Bugs"), link: "https://github.com/dawndiy/recorder/issues" })
                    creditsModel.append({ category: i18n.tr("Resources"), name: i18n.tr("Contact"), link: "mailto:dawndiy.dev@gmail.com" })

                    // Icon
                    creditsModel.append({ category: i18n.tr("Icon"), name: "DawnDIY", link: "https://github.com/dawndiy" })

                    // Developers
                    creditsModel.append({ category: i18n.tr("Developers"), name: "DawnDIY", link: "https://github.com/dawndiy" })

                    // Powered By
                    // creditsModel.append({ category: i18n.tr("Powered by"), name: "XXXX", link: "XXXX" })
                }

            }

            ListView {
                id: creditsListView

                model: creditsModel
                anchors.fill: parent
                section.property: "category"
                section.criteria: ViewSection.FullString
                section.delegate: ListItemHeader {
                    title: section
                }

                delegate: ListItem {
                    height: creditsDelegateLayout.height
                    divider.visible: false
                    highlightColor: "#246588"
                    ListItemLayout {
                        id: creditsDelegateLayout
                        title.text: model.name
                        title.color: "white"
                        ProgressionSlot { color: "white" }
                    }
                    onClicked: Qt.openUrlExternally(model.link)
                }
            }
        }
    }


    ListView {
        id: tabView
        anchors {
            top: parent.header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        model: tabs
        orientation: Qt.Horizontal
        snapMode: ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightMoveDuration: UbuntuAnimation.FastDuration

        onCurrentIndexChanged: {
            sections.selectedIndex = currentIndex
        }

    }
}
