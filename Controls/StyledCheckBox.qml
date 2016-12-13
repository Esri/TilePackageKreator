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

import ArcGIS.AppFramework 1.0

//------------------------------------------------------------------------------

CheckBox {
    property string fontFamily

    style: CheckBoxStyle {
        label: Item {
            implicitWidth: text.implicitWidth + 2
            implicitHeight: text.implicitHeight
            baselineOffset: text.baselineOffset
            
            Rectangle {
                anchors.fill: text
                anchors.margins: -1
                anchors.leftMargin: -3
                anchors.rightMargin: -3
                visible: control.activeFocus
                height: 6
                radius: 3
                color: "#224f9fef"
                border.color: "#47b"
                opacity: 0.6
            }
            
            Text {
                id: text
                text: control.text //StyleHelpers.stylizeMnemonics(control.text)
                anchors.centerIn: parent
                color: "black" //SystemPaletteSingleton.text(control.enabled)
                renderType: Text.QtRendering //Settings.isMobile ? Text.QtRendering : Text.NativeRendering
                font {
                    pointSize: 14
                    bold: false
                    family: fontFamily
                }
                textFormat: Text.RichText
            }
        }
    }
}
