/* Copyright 2016 Esri
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

import QtQuick 2.6
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
import "../singletons" as Singletons
//------------------------------------------------------------------------------

Rectangle{

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: mapDrawingToolMenu

    width: (parent.width < 700) ? sf(parent.width - 20) : sf(500)
    height: sf(58)
    color: "white"
    radius: sf(5)
    opacity: (!drawing) ? 1 : .4

    property int buttonWidth: sf(50)

    property bool drawing: false
    property bool drawingExists: false
    property string activeGeometryType: ""

    signal drawingRequest(string g)

    // UI //////////////////////////////////////////////////////////////////////

    RowLayout{
        anchors.fill: parent
        anchors.margins: sf(4)
        anchors.rightMargin: sf(6)
        spacing: 0

        Rectangle{
            id: infoBar
            readonly property var success: {
                "backgroundColor": "#DDEEDB",
                "borderColor": "#9BC19C"
            }

            readonly property var info: {
                "backgroundColor": "#D2E9F9",
                "borderColor": "#3B8FC4"
            }

            readonly property var warning: {
                "backgroundColor": "#F3EDC7",
                "borderColor": "#D9BF2B"
            }

            readonly property var error: {
                "backgroundColor": "#F3DED7",
                "borderColor": "#E4A793"
            }
            Layout.fillHeight: true
            Layout.preferredWidth: sf(200)

            RowLayout{
                anchors.fill: parent
                spacing: 0
                Rectangle{
                    color: "transparent"
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.height - sf(10)
                    Layout.rightMargin: sf(10)

                    Text {
                        anchors.centerIn: parent
                        font.pointSize: Singletons.Config.largeFontSizePoint * 1.2
                        font.family: iconFont
                        text: (!drawing) ? ( (!drawingExists) ? icons.warning : icons.checkmark ) : icons.happy_face
                    }
                }
                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    Text {
                        id: drawingNotice
                        anchors.fill: parent
                        font.family: notoRegular
                        verticalAlignment: Text.AlignVCenter
                        text: (!drawing) ? ( (!drawingExists) ? Singletons.Strings.drawAnExtentOrPath : Singletons.Strings.extentOrPathDrawn ) : (activeGeometryType === "envelope") ? Singletons.Strings.drawingExtent : Singletons.Strings.drawingPath
                    }
                }
            }
        }

        Rectangle{
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Rectangle{
            id: buttonContainer
            Layout.fillHeight: true
            Layout.preferredWidth: buttonWidth * drawingTypesModel.count
            color: "transparent"
            ListView{
                anchors.fill: parent
                model: drawingTypesModel
                delegate: drawingButtonComponent
                spacing: sf(2)
                layoutDirection: Qt.LeftToRight
                orientation: ListView.Horizontal
            }
        }
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    ListModel{

        id: drawingTypesModel

        ListElement{
            name: qsTr("Draw Rectangle")
            property bool available: true
            property string geometryType: "envelope"
            property url iconPath: "images/draw_extent.png"
            property string fontIcon: "draw_extent"
        }

        ListElement{
            name: qsTr("Draw Path")
            property bool available: true
            property string geometryType: "multipath"
            property url iconPath: "images/draw_path.png"
            property string fontIcon: "draw_path"
        }

    }

    //--------------------------------------------------------------------------

    Component{
        id: drawingButtonComponent

        Rectangle{
            width: buttonWidth
            height: parent.height
            color: "transparent"

            Button {
                anchors.fill: parent
                enabled: available
                visible: available
                property string g: geometryType
                ToolTip.text: name
                ToolTip.visible: hovered

                background: Rectangle {
                    anchors.fill: parent
                    color: parent.enabled ? ( parent.pressed ? "#bddbee" : "#fff" ) : (activeGeometryType === geometryType) ? app.info.properties.mainButtonBorderColor : "#eee"
                    border.width: parent.enabled ? app.info.properties.mainButtonBorderWidth : 0
                    border.color: parent.enabled ? app.info.properties.mainButtonBorderColor : "#ddd"
                    radius: sf(3)
                }

                RowLayout{
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.height
                        color: "transparent"

                        Text{
                            anchors.centerIn: parent
                            font.pointSize: Singletons.Config.largeFontSizePoint * 1.5
                            color: (activeGeometryType === geometryType) ? "#fff" : app.info.properties.mainButtonBorderColor
                            font.family: iconFont
                            text: icons[fontIcon]
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        visible: false
                        Text {
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: app.info.properties.mainButtonBorderColor
                            textFormat: Text.RichText
                            text: name
                            font.pointSize: Singletons.Config.baseFontSizePoint
                            font.family: notoRegular
                        }
                    }
                }

                onClicked: {
                    drawing = true;
                    drawingRequest(g);
                    activeGeometryType = g;
                }
            }
        }
    }

    // METHODS /////////////////////////////////////////////////////////////////

    function drawingRequestComplete(){
        drawing = false;
        activeGeometryType = "";
    }

    // END /////////////////////////////////////////////////////////////////////
}
