/* Copyright 2021 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.15
import QtQuick.Controls 2.15

import ArcGIS.AppFramework 1.0

Switch {
    id: control

    property color disabledColor: "grey"
    property color uncheckedColor: "red"
    property color checkedColor: "green"

    indicator: Rectangle {
        id: rect

        property color shadow: control.checked ? Qt.darker(highlight, 1.2): "#999"
        property color bg: control.checked ? highlight : uncheckedColor
        property color highlight: control.enabled ? checkedColor : disabledColor

        implicitWidth: Math.round(implicitHeight * 3)
        implicitHeight: 24 * AppFramework.displayScaleFactor

        border.color: "gray"
        color: "red"

        radius: 2
        Behavior on shadow {ColorAnimation{ duration: 80 }}
        Behavior on bg {ColorAnimation{ duration: 80 }}
        gradient: Gradient {
            GradientStop {color: rect.shadow; position: 0}
            GradientStop {color: rect.bg ; position: 0.2}
            GradientStop {color: rect.bg ; position: 1}
        }
        Rectangle {
            color: "#44ffffff"
            height: 1
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -1
            width: parent.width - 2
            x: 1
        }
    }



    
}
