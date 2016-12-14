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

AbstractButton {
    width: units.gu(4)
    height: parent ? parent.height : undefined
    action: modelData

    Rectangle {
        id: background
        color: parent.pressed ? "#76C8C4" : "transparent"
        anchors.fill: parent
    }

    Icon {
        id: icon
        anchors.centerIn: parent
        width: units.gu(2)
        height: width
        source: action.iconSource
        name: action.iconName
        color: "White"
        opacity: parent.enabled ? 1.0 : 0.4
    }
}
