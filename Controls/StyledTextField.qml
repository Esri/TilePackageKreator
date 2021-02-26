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

TextField {
    id: control
    selectByMouse: true

    background: Rectangle {
        anchors.fill: parent
        border.width: Singletons.Config.formElementBorderWidth
        border.color: Singletons.Colors.mediumGray
        radius: Singletons.Config.formElementRadius
        color: parent.enabled ? "#fff" : Singletons.Colors.lightGray
    }
    color: Singletons.Colors.darkGray
    font.family: defaultFontFamily
    font.pointSize: Singletons.Config.smallFontSizePoint

    Accessible.role: Accessible.EditableText
    Accessible.focusable: true
}
