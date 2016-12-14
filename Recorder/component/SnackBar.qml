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

Rectangle {
    id: snackBar

    property int duration: 3
    property alias text: snackBarText.text

    function show(message, show_duration) {
        if (show_duration) {
            duration = show_duration
        }
        if (message) {
            snackBar.text = message

            anchors.bottomMargin = 0
            opacity = 0.6
            snackBarTimer.start()
        }
    }

    width: parent.width
    height: snackBarText.height + units.gu(3)
    anchors {
        bottom: parent.bottom
        bottomMargin: -height
    }
    color: "#000"
    opacity: 0

    Component.onCompleted: {
        anchors.bottomMargin = 0
        opacity = 0.6
        snackBarTimer.start()
    }

    Text {
        id: snackBarText
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            right: parent.right
            rightMargin: units.gu(2)
            verticalCenter: parent.verticalCenter
        }
        text: ""
        wrapMode: Text.WrapAnywhere
        color: "white"
    }

    Timer {
        id: snackBarTimer
        interval: snackBar.duration * 1000
        running: false
        repeat: false
        triggeredOnStart: false
        onTriggered: {
            animaDestroy.start()
        }
    }

    SequentialAnimation {
        id: animaDestroy

        UbuntuNumberAnimation {
            target: snackBar.anchors
            property: "bottomMargin"
            to: -snackBar.height
            duration: 500; easing.type: Easing.InOutCirc
        }

        UbuntuNumberAnimation {
            target: snackBar
            property: "opacity"
            to: 0
            duration: 500; easing.type: Easing.InOutCirc
        }
    }


    Behavior on opacity {
        UbuntuNumberAnimation { duration: 500; easing.type: Easing.InOutCirc }
    }

    Behavior on anchors.bottomMargin {
        UbuntuNumberAnimation { duration: 500; easing.type: Easing.InOutCirc }
    }
}
