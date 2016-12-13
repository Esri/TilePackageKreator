/* Copyright 2015 Esri
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

import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1

//------------------------------------------------------------------------------

RowLayout {
    id: switchBox

    property alias checked: switchy.checked
    property alias text: text.text
    property color checkedColor: "black"
    property color uncheckedColor: "grey"
    property string fontFamily
    property alias font: text.font

    StyledSwitch {
        id: switchy
        enabled: parent.enabled
    }

    Text {
        id: text

        Layout.fillWidth: true

        color: checked && switchBox.enabled ? checkedColor : uncheckedColor
        renderType: Text.QtRendering
        font {
            pointSize: 14
            family: fontFamily
        }
        textFormat: Text.RichText
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }
}

