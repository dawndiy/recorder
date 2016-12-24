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
        screenSaverEnabled: !settings.disableScreenSaver || !Qt.application.active
    }

    Recorder {
        id: recorder

        readonly property var channelData: {
            'default_index': 0,
            'list': [ { name: '1', value: 1 }, { name: '2', value: 2 } ]
        }
        readonly property var qualityData: {
            'default_index': 2,
            'list': [
                // TRANSLATORS: This is a quality option in Record Quality.
                { name: i18n.tr("Very Low Quality"), value: 0},
                // TRANSLATORS: This is a quality option in Record Quality.
                { name: i18n.tr("Low Quality"), value: 1},
                // TRANSLATORS: This is a quality option in Record Quality.
                { name: i18n.tr("%1 (default)").arg(i18n.tr("Normal Quality")), value: 2},
                // TRANSLATORS: This is a quality option in Record Quality.
                { name: i18n.tr("High Quality"), value: 3},
                // TRANSLATORS: This is a quality option in Record Quality.
                { name: i18n.tr("Very High Quality"), value: 4}
            ]
        }
        readonly property var encodingModeData: {
            'default_index': 0,
            'list': [
                // TRANSLATORS: This is an option in Encoding Mode. It means set audio quality using defaults options.
                { name: i18n.tr("%1 (default)").arg(i18n.tr("Constant Quality")), value: 0},
                // TRANSLATORS: This is an option in Encoding Mode. It means set audio quality using bitrate.
                { name: i18n.tr("Constant Bitrate"), value: 1}
            ]
        }
        readonly property var bitrateData: {
            'default_index': 0,
            'list': [
                { name: i18n.tr("%1 (default)").arg('32000'), value: 32000 },
                { name: '64000', value: 64000 },
                { name: '128000', value: 128000 },
                { name: '192000', value: 192000 },
                { name: '256000', value: 256000 }
            ]
        }
        property var codecData: ({})
        property var containerData: ({})

        function getDataName(data, value) {
            var name = ''
            if (!data.list) {
                return name
            }

            if (value === -1 || value === "default") {
                return data.list[data.default_index].name
            }

            for (var i = 0; i < data.list.length; i++) {
                var item = data.list[i]
                if (item.value == value) {
                    name = item.name
                    break
                }
            }
            return name
        }

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
            // TRANSLATORS: This a reminder when some thing error.
            var tip = i18n.tr(" (Reset your settings will fix this.)")
            notification(errorMessage + tip, 5)
        }

        Component.onCompleted: {

            // detect audio codec
            var codec_list = recorder.supportedAudioCodecs()
            if (codec_list.length > 0) {
                recorder.codecData.list = []
            }
            for (var i = 0; i < codec_list.length; i++) {
                var codec = codec_list[i]
                var codec_item = { name: codec, value: codec}
                if (codec === "audio/vorbis") {
                    codec_item.name = i18n.tr("%1 (default)").arg(codec_item.name)
                    recorder.codecData.default_index = i
                }
                recorder.codecData.list.push(codec_item)
            }

            // detect file container
            var container_list = recorder.supportedContainers()
            if (container_list.length > 0) {
                recorder.containerData.list = []
            }
            for (var i = 0; i < container_list.length; i++) {
                var container = container_list[i]
                var container_item = { name: container, value: container }
                if (container === "ogg") {
                    container_item.name = i18n.tr("%1 (default)").arg(container_item.name)
                    recorder.containerData.default_index = i
                }
                recorder.containerData.list.push(container_item)
            }

            // console.log("---", JSON.stringify(recorder.codecData))
            // console.log("---", JSON.stringify(recorder.containerData))
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
