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
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
import "../singletons" as Singletons
import "../"
//------------------------------------------------------------------------------

Rectangle{

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: mapDrawingToolMenu

    anchors.fill: parent
    color: "white"
    opacity: (!drawing) ? 1 : .4

    property int buttonWidth: buttonContainer.height

    property bool drawing: false
    property bool drawingExists: false
    property string activeGeometryType: ""
    property bool historyAvailable: false
    property bool bookmarksAvailable: false
    property bool bookmarksPopupOpen: false
    property bool geoJsonInMemory: false
    property bool geoJsonPopupOpen: false

    signal drawingRequest(string g)
    signal bookmarksRequested()
    signal geoJsonFeatureRequested()

    // UI //////////////////////////////////////////////////////////////////////

    RowLayout{
        id: layoutView
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: height + sf(6)
            Canvas {
                anchors.fill: parent
                onPaint: {
                    if (available) {
                        var _width = height;
                        var ctx = getContext("2d");
                        ctx.fillStyle = Singletons.Colors.lightBlue;
                        ctx.beginPath();
                        ctx.moveTo(0, 0);
                        ctx.lineTo(_width,0);
                        ctx.lineTo(_width + sf(6), height / 2);
                        ctx.lineTo(_width,height);
                        ctx.lineTo(0,height);
                        ctx.closePath();
                        ctx.fill();
                    }
                }
            }
            Item {
                width: height
                height: parent.height
                anchors.left: parent.left
                IconFont {
                    anchors.centerIn: parent
                    icon: _icons.draw_tool
                    color: Singletons.Colors.mainButtonBackgroundColor
                    iconSizeMultiplier: 1.1
                }
            }
        }

        Rectangle {
            id: buttonContainer
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: sf(5)
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

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: height
            Layout.margins: sf(5)
            color: "#fff"
            Button {
                id: geojsonBtn
                anchors.fill: parent
                enabled: geoJsonInMemory
                visible: geoJsonInMemory
                ToolTip.text: qsTr("Shapefile or geojson data")
                ToolTip.visible: hovered

                background: Rectangle {
                    anchors.fill: parent
                    color: geoJsonPopupOpen ? app.info.properties.mainButtonBorderColor : "#fff"
                    border.width: app.info.properties.mainButtonBorderWidth
                    border.color: parent.enabled ? app.info.properties.mainButtonBorderColor : "#ddd"
                    radius: sf(3)
                }

                IconFont {
                    anchors.centerIn: parent
                    iconSizeMultiplier: 1.5
                    color: parent.enabled
                           ? geoJsonPopupOpen ? "#fff" : app.info.properties.mainButtonBorderColor
                           : "#ddd"
                    icon: _icons.geojson
                }

                onClicked: {
                    geoJsonFeatureRequested();
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: sf(1)
            color: Singletons.Colors.lightBlue
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: height
            Layout.margins: sf(5)
            color: "#fff"
            Button {
                anchors.fill: parent
                enabled: bookmarksAvailable
                visible: true
                ToolTip.text: Singletons.Strings.bookmarks
                ToolTip.visible: hovered

                background: Rectangle {
                    anchors.fill: parent
                    color: parent.enabled
                           ? bookmarksPopupOpen ? app.info.properties.mainButtonBorderColor : ( parent.pressed ? "#bddbee" : "#fff" )
                           : "#fff"
                    border.width: app.info.properties.mainButtonBorderWidth
                    border.color: parent.enabled ? app.info.properties.mainButtonBorderColor : "#ddd"
                    radius: sf(3)
                }

                IconFont {
                    anchors.centerIn: parent
                    iconSizeMultiplier: 1.5
                    color: parent.enabled
                           ? bookmarksPopupOpen ? "#fff" : app.info.properties.mainButtonBorderColor
                           : "#ddd"
                    icon: _icons.bookmark
                }

                onClicked: {
                    bookmarksRequested();
                }
            }
        }
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    ListModel{

        id: drawingTypesModel

        ListElement {
            name: qsTr("Draw Rectangle")
            property bool available: true
            property string geometryType: "envelope"
            property string fontIcon: "draw_extent"
        }

        ListElement {
            name: qsTr("Draw Polygon")
            property bool available: true
            property string geometryType: "polygon"
            property string fontIcon: "draw_polygon"
        }

        ListElement {
            name: qsTr("Draw Path")
            property bool available: true
            property string geometryType: "multipath"
            property string fontIcon: "draw_path"
        }

        ListElement {
            name: qsTr("Redraw Last")
            property bool available: true
            property string geometryType: "redraw"
            property string fontIcon: "redraw_last_path"
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: drawingButtonComponent

        Rectangle{
            width: buttonWidth
            height: parent.height
            color: "transparent"

            Button {
                anchors.fill: parent
                enabled: geometryType !== Singletons.Constants.kRedraw ? available : available && historyAvailable
                property string g: geometryType
                ToolTip.text: name
                ToolTip.visible: hovered

                background: Rectangle {
                    anchors.fill: parent
                    color: parent.enabled ? ( parent.pressed ? "#bddbee" : "#fff" ) : (activeGeometryType === geometryType) ? app.info.properties.mainButtonBorderColor : "#fff"
                    border.width: app.info.properties.mainButtonBorderWidth
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

                        IconFont {
                            anchors.centerIn: parent
                            iconSizeMultiplier: 1.5
                            color: parent.enabled ? (activeGeometryType === geometryType) ? "#fff" : app.info.properties.mainButtonBorderColor : "#ddd"
                            icon: _icons[fontIcon]
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
                            font.family: defaultFontFamily
                        }
                    }
                }

                onClicked: {
                    drawing = true;
                    activeGeometryType = g;
                    drawingRequest(g);
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
