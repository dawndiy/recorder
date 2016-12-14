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
import QtSystemInfo 5.0
import QtMultimedia 5.5
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3
// import Ubuntu.PerformanceMetrics 1.0
import AudioRecorder 1.0

import "ui"

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    id: root
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "audio-recorder.ubuntu-dawndiy"

    property string appVersion: "1.0.1"

    width: units.gu(50)
    height: units.gu(75)

    function notification(text, duration) {
        var noti = Qt.createComponent(Qt.resolvedUrl("component/SnackBar.qml"))
        noti.createObject(root, {text: text, duration: duration})
    }

    function showIntro() {
        // settings.version = ""
        // if (settings.version != root.appVersion) {
        //    pageLayout.forceSinglePage = true
        //    pageLayout.addPageToCurrentColumn(homePage, introPage)
        //}
    }

    Component.onCompleted: {
        showIntro()
    }

    Settings {
        id: settings

        property string version: ""

        property string audioCodec: "default"
        property string fileContainer: "default"
        property int channels: 1
        property int encodingMode: -1
        property int encodingQuality: -1
        property int bitrate: -1
        property int recordsSorting: 0
        property bool disableScreenSaver: true
        property bool showSoundWave: true
        property int microphoneVolume: 90
    }

    ScreenSaver {
        id: screenSaver
        screenSaverEnabled: !settings.disableScreenSaver
    }

    Recorder {
        id: recorder

        readonly property var channelList: [1, 2]
        readonly property var qualityList: [
            i18n.tr("Very Low Quality"),
            i18n.tr("Low Quality"),
            i18n.tr("Normal Quality"),
            i18n.tr("High Quality"),
            i18n.tr("Very High Quality")
        ]
        readonly property var encodingModeList: [
            i18n.tr("Constant Quality"),
            i18n.tr("Constant Bitrate")
        ]
        readonly property var bitrateList: [
            32000,
            64000,
            128000,
            192000,
            256000
        ]

        audioCodec: settings.audioCodec
        fileContainer: settings.fileContainer
        channels: settings.channels
        encodingMode: settings.encodingMode == -1 ?
                          Recorder.QualityMode : settings.encodingMode == 0 ?
                              Recorder.QualityMode : Recorder.BitrateMode
        encodingQuality: settings.encodingQuality == -1 ?
                             Recorder.NormalQuality : settings.encodingQuality
        bitrate: settings.bitrate == -1 ?
                     32000 : bitrateList[settings.bitrate]
        microphoneVolume: settings.microphoneVolume

        onError: {
            console.log(errorMessage)
            var tip = i18n.tr(" (Reset your settings will fix this.)")
            notification(errorMessage + tip, 5)
        }
    }

    MediaPlayer {
        id: player
    }


    // Venice Blue
    LinearGradient {
        opacity: 1
        anchors.fill: parent
        start: Qt.point(0, 0)
        end: Qt.point(parent.width, parent.height)
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#85D8CE" }
            GradientStop { position: 1.0; color: "#085078" }
        }
    }

    AdaptivePageLayout {
        id: pageLayout

        property bool forceSinglePage: true

        function addPageToNext(sourcePage, page, properties) {
            pageLayout.addPageToNextColumn(sourcePage, page, properties)
            forceSinglePage = false
        }

        function removePage(page) {
            pageLayout.removePages(page)
            forceSinglePage = true
        }

        anchors.fill: parent
        primaryPage: homePage
        layouts: PageColumnsLayout {

            when: width > units.gu(80) && !pageLayout.forceSinglePage
            PageColumn {
                minimumWidth: units.gu(50)
                maximumWidth: units.gu(80)
                preferredWidth: units.gu(50)
            }

            PageColumn {
                fillWidth: true
            }
        }

        HomePage {
            id: homePage
        }

        IntroPage {
            id: introPage

            onStartApp: {
                pageLayout.forceSinglePage = false
                pageLayout.removePages(introPage)
                settings.version = root.appVersion
            }
        }
    }

//    PerformanceOverlay {
//        active: true
//    }

    Connections {
        target: ContentHub
        onExportRequested: {
            console.debug("Export Requested")
            pageLayout.addPageToCurrentColumn(
                        homePage, Qt.resolvedUrl("ui/RecordsPage.qml"),
                        { state: "exporter", transfer: transfer })
        }
    }
}
