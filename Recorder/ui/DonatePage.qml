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
    id: donatePage

    property int selectdIndex: 0

    header: PageHeader {
        title: i18n.tr("Donate")

        leadingActionBar.delegate: HeaderButton {}
        trailingActionBar.delegate: HeaderButton {}

        StyleHints {
            foregroundColor: "#FFF"
            backgroundColor: "#85D8CE"
            dividerColor: "#85D8CE"
        }
    }

    onSelectdIndexChanged: {
        switch (selectdIndex) {
        case 0:
            qrCodeImage.source = Qt.resolvedUrl("../image/alipay_qrcode.png")
            break;
        case 1:
            qrCodeImage.source = Qt.resolvedUrl("../image/wechat_qrcode.png")
            break;
        }
    }

    Component.onCompleted: {
        qrCodeImage.source = Qt.resolvedUrl("../image/alipay_qrcode.png")
    }

    Row {
        id: paymentRow
        anchors {
            top: parent.header.bottom
            topMargin: units.gu(2)
            left: parent.left
            leftMargin: units.gu(2)
            right: parent.right
            rightMargin: units.gu(2)
        }

        Item {
            width: parent.width / 3
            height: width
            UbuntuShape {
                id: alipayItem
                anchors.centerIn: parent
                source: Image {
                    source: Qt.resolvedUrl("../image/alipay.png")
                }
                aspect: UbuntuShape.DropShadow
                opacity: (selectdIndex === 0 || alipayMouseArea.pressed) ? 1 : 0.55

                MouseArea {
                    id: alipayMouseArea
                    anchors.fill: parent
                    onClicked: {
                        donatePage.selectdIndex = 0
                    }
                }
            }

            Rectangle {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: alipayItem.bottom
                    topMargin: units.gu(1)
                }
                width: units.gu(1)
                height: width
                radius: width / 2
                color: "#85D8CE"
                visible: donatePage.selectdIndex === 0
            }
        }

        Item {
            width: parent.width / 3
            height: width
            UbuntuShape {
                id: wechatItem
                anchors.centerIn: parent
                source: Image {
                    source: Qt.resolvedUrl("../image/wechat.png")
                }
                aspect: UbuntuShape.DropShadow
                opacity: (selectdIndex === 1 || wechatMouseArea.pressed) ? 1 : 0.55

                MouseArea {
                    id: wechatMouseArea
                    anchors.fill: parent
                    onClicked: {
                        donatePage.selectdIndex = 1
                    }
                }
            }

            Rectangle {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: wechatItem.bottom
                    topMargin: units.gu(1)
                }
                width: units.gu(1)
                height: width
                radius: width / 2
                color: "#85D8CE"
                visible: donatePage.selectdIndex === 1
            }
        }

        Item {
            width: parent.width / 3
            height: width
            UbuntuShape {
                id: paypalItem
                anchors.centerIn: parent
                source: Image {
                    source: Qt.resolvedUrl("../image/paypal.png")
                }
                aspect: UbuntuShape.DropShadow
                opacity: (selectdIndex === 2 || paypalMouseArea.pressed) ? 1 : 0.55

                MouseArea {
                    id: paypalMouseArea
                    anchors.fill: parent
                    onClicked: {
                        Qt.openUrlExternally("https://paypal.me/dawndiy")
                    }
                }
            }
        }
    }

    Item {
        width: parent.width - units.gu(4)
        height: donateText.height
        anchors {
            bottom: parent.bottom
            bottomMargin: units.gu(2.5)
            horizontalCenter: parent.horizontalCenter
        }

        Label {
            id: donateText
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n.tr("Please donate if you like this App. :)")
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: "#88FFFFFF"
        }
    }

    Image {
        id: qrCodeImage
        width: parent.width > parent.height - parent.header.height - paymentRow.height - units.gu(2) ?
                   parent.height - parent.header.height - paymentRow.height - units.gu(12) :
                   parent.width - units.gu(20)
        height: width
        anchors {
            top: paymentRow.bottom
            topMargin: units.gu(2)
            horizontalCenter: parent.horizontalCenter
        }
        opacity: 1
    }
}
