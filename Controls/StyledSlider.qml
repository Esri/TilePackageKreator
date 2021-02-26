/* Copyright 2018 Esri
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
import QtQuick.Controls 2.2
import "../singletons" as Singletons

Slider {
    id: control

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        //implicitWidth: parent.width
        //implicitHeight: sf(4)
        width: control.availableWidth
        height: sf(4)
        radius: sf(2)
        color: Singletons.Colors.mediumGray

        Rectangle {
            width: control.visualPosition * parent.width - x
            height: parent.height
            color: Singletons.Colors.mediumGray
            radius: 2
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: sf(18)
        implicitHeight: sf(18)
        radius: sf(9)
        color: pressed ? Singletons.Colors.mainButtonPressedColor : Singletons.Colors.mainButtonBackgroundColor
        border.color: "#fff"
        border.width: sf(2)
    }

}
