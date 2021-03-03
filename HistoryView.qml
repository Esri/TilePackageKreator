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
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
//------------------------------------------------------------------------------
import "singletons" as Singletons
//------------------------------------------------------------------------------

Item {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: historyView

    property bool exportHistoryExists: false
    property bool uploadHistoryExists: false

    // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////////

    Component.onCompleted: {
    }

    //--------------------------------------------------------------------------

    StackView.onActivating: {
        mainView.appToolBar.enabled = true;
        mainView.appToolBar.historyButtonEnabled = false;
        mainView.appToolBar.settingsButtonEnabled = true;
        mainView.appToolBar.backButtonEnabled = true;
        mainView.appToolBar.backButtonVisible = true;
        mainView.appToolBar.toolBarTitleLabel = Singletons.Strings.exportAndUploadHistory;
    }
    StackView.onActivated: {
        getExportHistory();
        getUploadHistory();
    }

    // UI //////////////////////////////////////////////////////////////////////

    RowLayout {
        anchors.fill: parent
        anchors.margins: sf(10)
        anchors.topMargin: 0
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            Rectangle {
                anchors.fill: parent
                anchors.rightMargin: sf(10)

                color: "#fff"

                ColumnLayout {
                    spacing: 0
                    anchors.fill: parent

                    Rectangle {
                        Layout.preferredHeight: sf(50)
                        Layout.fillWidth: true

                        RowLayout {
                            anchors.fill: parent
                            Text {
                                id: exportHistoryLabel
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                text: Singletons.Strings.exportHistory
                                font.pointSize: Singletons.Config.mediumFontSizePoint
                                font.family: defaultFontFamily
                                verticalAlignment: Text.AlignVCenter
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.preferredWidth: sf(150)
                                Button {
                                    anchors.fill: parent
                                    enabled: exportHistoryExists
                                    visible: exportHistoryExists

                                    background: Rectangle {
                                        anchors.fill: parent
                                        color: Singletons.Config.buttonStates(parent, "clear")
                                        radius: app.info.properties.mainButtonRadius
                                        border.width: parent.enabled ? app.info.properties.mainButtonBorderWidth : 0
                                        border.color: "#fff"
                                    }

                                    Text {
                                        color: app.info.properties.mainButtonBackgroundColor
                                        anchors.centerIn: parent
                                        textFormat: Text.RichText
                                        text: Singletons.Strings.deleteHistory
                                        font.pointSize: Singletons.Config.baseFontSizePoint
                                        font.family: defaultFontFamily
                                    }

                                    onClicked: {
                                        appDatabase.truncate("exports")
                                        getExportHistory();
                                    }
                                }

                            }
                        }
                    }

                    // ---------------------------------------------------------

                    Rectangle{
                        Layout.preferredHeight: sf(1)
                        Layout.fillWidth: true
                        Layout.bottomMargin: sf(10)
                        color: "#ddd"
                    }

                    // ---------------------------------------------------------

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        Flickable {
                            id: exportFlickable
                            anchors.fill: parent
                            contentHeight: exportHistoryTextArea.height
                            clip: true
                            flickableDirection: Flickable.VerticalFlick
                            TextArea {
                                id: exportHistoryTextArea
                                width: parent.width
                                textFormat: Text.RichText
                                readOnly: true
                                font.pointSize: Singletons.Config.baseFontSizePoint
                                color: app.info.properties.toolBarBackgroundColor
                                wrapMode: Text.Wrap
                                onLinkActivated: {
                                    Qt.openUrlExternally(link);
                                }
                                Component.onCompleted: {
                                    exportFlickable.contentY = 0;
                                }
                            }
                        }
                    }
                }
            }
        }

        //------------------------------------------------------------------

        Rectangle {
            Layout.preferredWidth: sf(1)
            Layout.fillHeight: true
            color: app.info.properties.toolBarBackgroundColor
        }

        //------------------------------------------------------------------

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: sf(10)
                color:"white"

                ColumnLayout {
                    spacing: 0
                    anchors.fill: parent

                    Rectangle {
                        Layout.preferredHeight: sf(50)
                        Layout.fillWidth: true

                        RowLayout {
                            anchors.fill: parent
                            Text {
                                id: uploadHistoryLabel
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                text: Singletons.Strings.uploadHistory
                                font.pointSize: Singletons.Config.mediumFontSizePoint
                                font.family: defaultFontFamily
                                verticalAlignment: Text.AlignVCenter
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.preferredWidth: sf(150)

                                Button {
                                    anchors.fill: parent
                                    enabled: uploadHistoryExists
                                    visible: uploadHistoryExists
                                    background: Rectangle {
                                        anchors.fill: parent
                                        color: Singletons.Config.buttonStates(parent, "clear")
                                        radius: app.info.properties.mainButtonRadius
                                        border.width: parent.enabled ? app.info.properties.mainButtonBorderWidth : 0
                                        border.color: "#fff"
                                    }

                                    Text {
                                        color: app.info.properties.mainButtonBackgroundColor
                                        anchors.centerIn: parent
                                        textFormat: Text.RichText
                                        text: Singletons.Strings.deleteHistory
                                        font.pointSize: Singletons.Config.baseFontSizePoint
                                        font.family: defaultFontFamily
                                    }

                                    onClicked: {
                                        appDatabase.truncate("uploads");
                                        getUploadHistory();
                                    }
                                }
                            }
                        }
                    }

                    // ---------------------------------------------------------

                    Rectangle {
                        Layout.preferredHeight: sf(1)
                        Layout.fillWidth: true
                        Layout.bottomMargin: sf(10)
                        color: "#ddd"
                    }

                    // ---------------------------------------------------------

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Flickable {
                            id: uploadFlickable
                            anchors.fill: parent
                            contentHeight: uploadHistoryTextArea.height
                            clip: true
                            flickableDirection: Flickable.VerticalFlick
                            TextArea {
                                id: uploadHistoryTextArea
                                width: parent.width
                                textFormat: Text.RichText
                                readOnly: true
                                font.pointSize: Singletons.Config.baseFontSizePoint
                                color: app.info.properties.toolBarBackgroundColor
                                wrapMode: Text.Wrap
                                onLinkActivated: {
                                    Qt.openUrlExternally(link);
                                }
                                Component.onCompleted: {
                                    uploadFlickable.contentY = 0;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // METHODS /////////////////////////////////////////////////////////////////

    function getExportHistory(){
        var exportHistory = appDatabase.read("SELECT * FROM 'exports' WHERE user IS '%1' ORDER BY OBJECTID DESC".arg(portal.user.email));
        exportHistoryTextArea.text = "";
        if (exportHistory !== null && exportHistory.count > 0) {
            for (var i=0; i < exportHistory.count; i++) {
               var entry = exportHistory.get(i);
               exportHistoryTextArea.append("<h3 style=\"color:darkorange;\">" + entry.title + "</h3>");
               exportHistoryTextArea.append("<p>" + new Date(entry.transaction_date).toLocaleDateString() + " " + new Date(entry.transaction_date).toLocaleTimeString() + "</p>");
               exportHistoryTextArea.append("<h4>Tile Service</h4>");
               exportHistoryTextArea.append(entry.tile_service_name);
               var extent = JSON.parse(entry.esri_geometry)
               exportHistoryTextArea.append("<h4>Geometry</h4>");
                    exportHistoryTextArea.append("<p>" + JSON.stringify(extent.geometries) + "<br/>");
                    if (extent.hasOwnProperty("buffer")) {
                        exportHistoryTextArea.append("Buffer: " + entry.buffer + "</p><hr/>");
                    }
                    exportHistoryTextArea.append("Type: " + extent.geometryType + "</p><hr/>");
               exportHistoryTextArea.append("<h4>Export Parameters</h4>");
               exportHistoryTextArea.append("<p>Levels: " + entry.levels + "</p>");
               exportHistoryTextArea.append("<p>Package Size: " + entry.package_size + "</p>");
               exportHistoryTextArea.append("<p>Number of Tiles: " + entry.number_of_tiles + "</p>");
               exportHistoryTextArea.append("<p>Description: " + entry.description + "</p>");
               exportHistoryTextArea.append("<h4>File Information</h4>");
               exportHistoryTextArea.append("<p>Local File Path: " + entry.local_filepath + "</p>");
               exportHistoryTextArea.append("<a href=\"" + entry.download_url + "\">Download Link [link may have expired]</a>");
             }
            exportHistoryExists = true;
        }
        else {
            exportHistoryTextArea.append("<p>No Export History Available<p>");
            exportHistoryExists = false;
        }
    }

    //--------------------------------------------------------------------------

    function getUploadHistory(){
        var uploadHistory = appDatabase.read("SELECT * FROM 'uploads' WHERE user IS '%1' ORDER BY OBJECTID DESC".arg(portal.user.email));
        uploadHistoryTextArea.text = "";
        if (uploadHistory !== null && uploadHistory.count > 0) {
            for (var i=0; i < uploadHistory.count; i++) {
               var entry = uploadHistory.get(i);
               uploadHistoryTextArea.append("<h3 style=\"color:darkblue;\">" + entry.title + "</h3>");
               uploadHistoryTextArea.append("<p>" + new Date(entry.transaction_date).toLocaleDateString() + " " + new Date(entry.transaction_date).toLocaleTimeString() + "</p>");
               uploadHistoryTextArea.append("<p>Description: " + entry.description + "</p>");
               uploadHistoryTextArea.append("<a href=\"" + entry.published_service_url + "\">Published ArcGIS Service Link</a>");
            }
            uploadHistoryExists = true;
        }
        else {
            uploadHistoryTextArea.append("<p>No Upload History Available<p>");
            uploadHistoryExists = false;
        }
    }

    // END /////////////////////////////////////////////////////////////////////
}
