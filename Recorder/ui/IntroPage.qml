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

Page {
    id: introPage

    header: Item { visible: false }

    signal startApp()

    Text {
        anchors {
            top: parent.top
            topMargin: units.gu(2)
            right: parent.right
            rightMargin: units.gu(2)
        }
        z: 10
        color: "white"
        // TRANSLATORS: The text of the button to skip the introduction page.
        text: i18n.tr("Skip")

        MouseArea {
            anchors.fill: parent
            onClicked: startApp()
        }
    }

    ListModel {
        id: introListModel

        function init() {
            append({
                // TRANSLATORS: The title of introduction page
                "title": i18n.tr("Easy to recording"),
                "body": i18n.tr("1. Record button to start recording.\n2. Play button to play recording.\n3. Stop button to stop recording or play.")
            })
            append({
                // TRANSLATORS: The title of introduction page
                "title": i18n.tr("Rich set of options"),
                "body": i18n.tr("1. Reset action to restore the default settings.\n2. Expand more advanced settings.")
            })
            append({
                // TRANSLATORS: The title of introduction page
                "title": i18n.tr("Easy-to-use recorded file list"),
                "body": i18n.tr("1. Rename recorded file.\n2. Check out recording informations.\n3. Delete recorded file.\n4. Click item to play recording directly.")
            })
            append({
                "title": "",
                "body": ""
            })
        }

        Component.onCompleted: {
            init()
        }
    }

    ListView {
        id: slider
        anchors.fill: parent
        z: 1

        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: width
        clip: true
        highlightFollowsCurrentItem: true
        highlightRangeMode: ListView.StrictlyEnforceRange

        model: introListModel
        delegate: Item {
            width: slider.width
            height: slider.height

            Text {
                id: titleText
                anchors {
                    bottom: bodyText.top
                    bottomMargin: units.gu(0.5)
                    horizontalCenter: parent.horizontalCenter
                }

                width: parent.width - units.gu(6)
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                horizontalAlignment: TextInput.AlignHCenter
                font.pixelSize: FontUtils.sizeToPixels("large")
                color: "#FFF"
                text: title
            }

            Text {
                id: bodyText
                anchors {
                    bottom: parent.bottom
                    bottomMargin: units.gu(10)
                    horizontalCenter: parent.horizontalCenter
                }

                width: parent.width - units.gu(6)
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                horizontalAlignment: TextInput.AlignLeft
                font.pixelSize: FontUtils.sizeToPixels("normal")
                color: "#FFF"
                text: body
            }

            Button {
                visible: index == introListModel.count - 1
                anchors {
                    bottom: parent.bottom
                    bottomMargin: units.gu(10)
                    horizontalCenter: parent.horizontalCenter
                }
                color: UbuntuColors.green
                // TRANSLATORS: Start App
                text: i18n.tr("Start")
                onClicked: startApp()
            }
        }

        onCurrentIndexChanged: {
            var file_name = "intro_" + (currentIndex) + ".png"
            introImage.source = Qt.resolvedUrl("../image/" + file_name)
        }
    }

    CrossFadeImage {
        id: introImage

        anchors {
            top: parent.top
            topMargin: units.gu(5)
            left: parent.left
            leftMargin: units.gu(4)
            right: parent.right
            rightMargin: units.gu(4)
            bottom: indicator.top
            bottomMargin: units.gu(20)
        }
        fadeDuration: UbuntuAnimation.SlowDuration

        // source: Qt.resolvedUrl("../image/intro_0.png")
    }

    Row {
        id: indicator
        height: units.gu(4)
        spacing: units.dp(8)
        anchors {
            bottom: parent.bottom
            bottomMargin: units.gu(2)
            horizontalCenter: parent.horizontalCenter
        }
        z: 2

        Repeater {
            model: introListModel.count
            delegate: Rectangle {
                height: width
                width: units.dp(6)
                radius: width / 2
                antialiasing: true
                color: slider.currentIndex == index ? "#2ca5e0" : "#bbbbbb"
                Behavior on color {
                    ColorAnimation {
                        duration: UbuntuAnimation.FastDuration
                    }
                }
            }
        }
    }
}
