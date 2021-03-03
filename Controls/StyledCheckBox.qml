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
import "../"
import "../singletons" as Singletons


//------------------------------------------------------------------------------

CheckBox {

    id: control
    checked: false
    opacity: enabled ? 1 : .4

    objectName: "ThemeCheckBox"

    property string label: "Checkbox"
    property string tooltip: ""
    property bool displayTooltip: tooltip > "" ? true : false
    property double fontSizeMultiplier: 1

    ToolTip.visible: displayTooltip && hovered
    ToolTip.text: tooltip

    Accessible.role: Accessible.CheckBox
    Accessible.name: control.label
    Accessible.description: control.label
    Accessible.focusable: true

    indicator: Rectangle {
        height: parent.height > sf(20) ? sf(20) : parent.height
        width: height
        border.color: Singletons.Colors.darkGray
        color: "transparent"
        anchors.verticalCenter: parent.verticalCenter

        IconFont {
            anchors.centerIn: parent
            icon: _icons.checkmark
            iconSizeMultiplier: .6
            color: Singletons.Colors.mainButtonBackgroundColor
            Accessible.ignored: true
            visible: control.checked
        }
    }

    contentItem: Text {
        text: control.label
        horizontalAlignment: !Singletons.Config.rtl ? Text.AlignLeft : Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        leftPadding: !Singletons.Config.rtl ? control.indicator.width + (6 * AppFramework.displayScaleFactor) : 0
        rightPadding: !Singletons.Config.rtl ? 0 : control.indicator.width + (6 * AppFramework.displayScaleFactor)
        color: Singletons.Colors.formElementFontColor
        textFormat: Text.RichText
        wrapMode: Text.Wrap
        font {
            family: defaultFontFamily
            pointSize: Singletons.Config.baseFontSizePoint * control.fontSizeMultiplier
        }
        onLinkActivated: {
            Qt.openUrlExternally(link);
        }
    }

    // END /////////////////////////////////////////////////////////////////////


    property string fontFamily

//    style: CheckBoxStyle {
//        label: Item {
//            implicitWidth: text.implicitWidth + 2
//            implicitHeight: text.implicitHeight
//            baselineOffset: text.baselineOffset
            
//            Rectangle {
//                anchors.fill: text
//                anchors.margins: -1
//                anchors.leftMargin: -3
//                anchors.rightMargin: -3
//                visible: control.activeFocus
//                height: 6
//                radius: 3
//                color: "#224f9fef"
//                border.color: "#47b"
//                opacity: 0.6
//            }
            
//            Text {
//                id: text
//                text: control.text //StyleHelpers.stylizeMnemonics(control.text)
//                anchors.centerIn: parent
//                color: "black" //SystemPaletteSingleton.text(control.enabled)
//                renderType: Text.QtRendering //Settings.isMobile ? Text.QtRendering : Text.NativeRendering
//                font {
//                    pointSize: 14
//                    bold: false
//                    family: fontFamily
//                }
//                textFormat: Text.RichText
//            }
//        }
//    }
}
