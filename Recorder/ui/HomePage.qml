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
import QtGraphicalEffects 1.0
import Ubuntu.Components 1.3
import AudioRecorder 1.0
import "../component"

Page {
    id: home

    header: PageHeader {
        title: i18n.tr("Recorder")
        opacity: 1

        leadingActionBar.delegate: HeaderButton {}
        trailingActionBar.delegate: HeaderButton {}

        leadingActionBar.actions: [
            Action {
                iconName: "media-playlist"
                // TRANSLATORS: This is a tab action name. This action button will enter a page show recorded files.
                text: i18n.tr("Records")
                onTriggered: {
                    home.pageStack.addPageToCurrentColumn(
                                home, Qt.resolvedUrl("RecordsPage.qml"))
                }
            },
            Action {
                iconName: "settings"
                text: i18n.tr("Settings")
                onTriggered: {
                    home.pageStack.addPageToNext(
                                home, Qt.resolvedUrl("SettingsPage.qml"))
                }
            }
        ]

        trailingActionBar.actions: [
            Action {
                iconName: "info"
                text: i18n.tr("About")
                onTriggered: {
                    pageStack.addPageToNext(
                                home, Qt.resolvedUrl("AboutPage.qml"))
                }
            }
        ]

        StyleHints {
            foregroundColor: "#FFF"
            backgroundColor: "#85D8CE"
            dividerColor: "#85D8CE"
        }
    }

    Label {
        id: durationLabel

        function reset() {
            text = "00:00"
        }

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

        anchors {
            top: parent.header.bottom
            topMargin: root.height > root.width ? units.gu(10) : units.gu(4)
            horizontalCenter: parent.horizontalCenter
        }
        // textSize: Label.XLarge
        font.pixelSize: units.gu(10)
        text: "00:00"
        color: "#EEE"
        opacity: 1

        style: Text.Raised
        styleColor: "#85D8CE"

        Connections {
            target: recorder
            onRecordTimeChanged: durationLabel.setTime(duration)
        }

        Connections {
            target: player
            onPositionChanged: durationLabel.setTime(
                                   player.duration - player.position)
        }

        Timer {
            id: pauseTimer
            interval: 500
            repeat: true
            running: recorder.recordState === Recorder.PausedState ? true : false
            onTriggered: {
                durationLabel.opacity = durationLabel.opacity == 1 ? 0.1 : 1
            }
            onRunningChanged: {
                durationLabel.opacity = 1
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 500; easing.type: Easing.InOutCubic }
        }
    }

    Item {
        id: wave
        visible: settings.showSoundWave
        anchors {
            left: parent.left
            right: parent.right
            bottom: control.top
            bottomMargin: units.gu(4)
        }
        height: (home.height - home.header.height - durationLabel.height - control.height - units.gu(16)) > units.gu(10) ?
                    units.gu(10) :
                    home.height - home.header.height - durationLabel.height - control.height - units.gu(16)
        width: parent.width
        opacity: 0

        Behavior on opacity {
            NumberAnimation { duration: 1000; easing.type: Easing.InOutCubic }
        }

        Canvas {
            id: waveCanvas

            property double level: 0.0
            property int periodCount: 2
            property int offset: 0

            function drawWave() {

                if (!wave.visible) {
                    return
                }

                var ctx = getContext("2d")
                ctx.save()
                ctx.reset()
                var grad = ctx.createLinearGradient(0, 0, width, 0);
                grad.addColorStop(0, "#246F8B");
                grad.addColorStop(1, "#62B2B6");
                ctx.strokeStyle = grad;
                ctx.lineWidth = units.gu(0.4);
                ctx.lineCap = "round"
                ctx.lineJoin = "round"

                ctx.beginPath()

                var r = (height - units.gu(1)) / 2
                var x = 0, y = 0
                var amplitude = r * level
                if (offset >= 2 *Math.PI) {
                    offset = 0
                }
                offset += Math.PI / 2

                for (var i = 0; i < width; i++) {
                    var w = i * Math.PI / 180 * 360 / width * periodCount + offset
                    x = amplitude * Math.cos(w)
                    y = r - amplitude * Math.sin(w) + units.gu(0.5)
                    ctx.lineTo(i, y)
                }

                ctx.stroke()
                ctx.restore()
            }

            anchors.fill: parent

            onPaint: {
                drawWave()
            }
        }
    }

    Item {
        id: control

        width: parent.width
        height: units.gu(10)

        anchors {
            bottom: parent.bottom
            bottomMargin: units.gu(8)
        }

        Rectangle {
            id: btnRecord
            anchors {
                horizontalCenter: parent.horizontalCenter
            }

            width: units.gu(13)
            height: width

            radius: width / 2
            color: recordMouseArea.pressed ? "#9976C8C4" : "#FF4997A5"


            Rectangle {
                id: recordVolume
                visible: recorder.recordState === Recorder.RecordingState
                anchors.centerIn: parent
                height: width
                radius: width / 2
                color: "#0085D8CE"
                RadialGradient {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#FF85D8CE" }
                        GradientStop { position: 0.25; color: "#FF85D8CE" }
                        GradientStop { position: 0.5; color: "#0085D8CE" }
                    }
                }
            }

            Icon {
                id: recordIcon
                anchors.centerIn: parent
                width: units.gu(6)
                height: width
                name: "media-record"
            }

            MouseArea {
                id: recordMouseArea
                anchors.fill: parent
                onClicked: {
                    Haptics.play()

                    if (player.playbackState !== MediaPlayer.StoppedState) {
                        player.stop()
                    }

                    console.debug(recorder.recordState)

                    switch (recorder.recordState) {
                    case Recorder.StoppedState:
                        durationLabel.reset()
                        recorder.record()
                        break;

                    case Recorder.RecordingState:
                        recorder.pause()
                        break;

                    case Recorder.PausedState:
                        recorder.resume()
                        break;
                    }
                }
            }

            Connections {
                target: recorder
                onVolumeLevelChanged: {
                    var t = new Date()
                    recordVolume.width = (units.gu(12)-recordIcon.width) * level + recordIcon.width

                    waveCanvas.level = level
                    waveCanvas.requestPaint()
                }
            }
        }

        Icon {
            id: btnStop
            width: units.gu(5)
            height: width
            anchors {
                right: btnRecord.left
                rightMargin: units.gu(5)
                verticalCenter: btnRecord.verticalCenter
            }
            name: "media-playback-stop"
            color: "#EEE"

            opacity: recorder.recordState !== Recorder.StoppedState || player.playbackState !== MediaPlayer.StoppedState ? 1.0 : 0.3

            MouseArea {
                id: btnStopMouseArea
                anchors.fill: parent
                onClicked: {

                    if (recorder.recordState !== Recorder.StoppedState) {
                        Haptics.play()
                        recorder.stop()
                        var absFilePath = recorder.filePath +
                                "/" + recorder.fileName
                        player.source = Qt.resolvedUrl("file://" + absFilePath)
                        notification(i18n.tr("Record is saved in %1").arg(absFilePath))

                    }

                    if (player.playbackState !== MediaPlayer.StoppedState) {
                        Haptics.play()
                        player.stop()
                        durationLabel.reset()
                    }
                }
            }
        }

        Rectangle {
            visible: btnStopMouseArea.pressed && btnStop.opacity == 1.0
            width: btnStop.width + units.gu(4)
            height: width
            anchors.centerIn: btnStop
            radius: width / 2
            color: "#CC4997A5"
        }

        Glow {
            opacity: btnStop.opacity
            anchors.fill: btnStop
            radius: 8
            samples: 17
            color: "#85D8CE"
            source: btnStop
        }

        Icon {
            id: btnPlay
            width: units.gu(5)
            height: width
            anchors {
                left: btnRecord.right
                leftMargin: units.gu(5)
                verticalCenter: btnRecord.verticalCenter
            }
            name: "media-playback-start"
            color: "#EEE"
            opacity: recorder.recordState !== Recorder.StoppedState || player.source != "" ? 1.0 : 0.3

            MouseArea {
                id: btnPlayMouseArea
                anchors.fill: parent
                onClicked: {

                    if (recorder.recordState !== Recorder.StoppedState) {
                        Haptics.play()
                        recorder.stop()
                        var absFilePath = recorder.filePath +
                                "/" + recorder.fileName
                        player.source = Qt.resolvedUrl("file://" + absFilePath)
                        notification(i18n.tr("Record is saved in %1").arg(absFilePath))
                    }

                    if (player.source != "") {
                        Haptics.play()
                        if (player.playbackState !== MediaPlayer.PlayingState) {
                            player.play()
                        } else {
                            player.pause()
                        }
                    } else if (recorder.fileName != "") {
                        Haptics.play()
                        var absluteFilePath = recorder.filePath +
                                "/" + recorder.fileName
                        player.source = Qt.resolvedUrl("file://" + absluteFilePath)
                        player.play()
                    }
                }
            }

            Connections {
                target: player
                onPlaybackStateChanged: {
                    switch (player.playbackState) {
                    case MediaPlayer.StoppedState:
                    case MediaPlayer.PausedState:
                        btnPlay.name = "media-playback-start"
                        break;
                    case MediaPlayer.PlayingState:
                        btnPlay.name = "media-playback-pause"
                        break;
                    }
                }
            }
        }

        Rectangle {
            visible: btnPlayMouseArea.pressed && btnPlay.opacity == 0.1
            width: btnPlay.width + units.gu(4)
            height: width
            anchors.centerIn: btnPlay
            radius: width / 2
            color: "#CC4997A5"
        }

        Glow {
            opacity: btnPlay.opacity
            anchors.fill: btnPlay
            radius: 8
            samples: 17
            color: "#85D8CE"
            source: btnPlay
        }

        Connections {
            target: recorder
            onRecordStateChanged: {
                switch (state) {
                case Recorder.StoppedState:
                    recordIcon.name = "media-record"
                    recordIcon.color = ""
                    wave.opacity = 0
                    break;
                case Recorder.RecordingState:
                    recordIcon.name = "media-playback-pause"
                    recordIcon.color = "white"
                    wave.opacity = 1
                    break;
                case Recorder.PausedState:
                    recordIcon.name = "media-record"
                    recordIcon.color = ""
                    break;
                }
            }
        }
    }
}
