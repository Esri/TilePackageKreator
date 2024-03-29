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
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
//------------------------------------------------------------------------------
import "../"
import "../singletons" as Singletons
//------------------------------------------------------------------------------

Dialog {

    id: updatesDialog

    property AppMetrics metrics
    property ListModel updates: ListModel {}

    width: 500 * AppFramework.displayScaleFactor
    height: 500 * AppFramework.displayScaleFactor
    modality: Qt.WindowModal
    title: qsTr("Available Updates for") + " " + app.info.title

    //--------------------------------------------------------------------------
    contentItem: Rectangle {
        anchors.fill: parent
        anchors.margins: 20 * AppFramework.displayScaleFactor
        anchors.topMargin: 5 * AppFramework.displayScaleFactor
        anchors.bottomMargin: 5 * AppFramework.displayScaleFactor
        color: "#eee"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            //----------------------------------------------------------------------
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40 * AppFramework.displayScaleFactor
                color: Singletons.Colors.subtleBackground

                Text {
                    anchors.fill: parent
                    anchors.bottomMargin: 5 * AppFramework.displayScaleFactor
                    text: updatesDialog.title
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: Singletons.Config.largeFontSizePoint
                    color: Singletons.Colors.formElementFontColor
                }
            }

            //----------------------------------------------------------------------
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    anchors.fill: parent
                    model: updates
                    spacing: 0

                    delegate: Rectangle {
                        height: 50 * AppFramework.displayScaleFactor
                        width: ListView.view.width

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0
                            //--------------------------------------------------
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 0
                                    //------------------------------------------
                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Text {
                                            anchors.fill: parent
                                            text: "%1 %2".arg(qsTr("Version")).arg(version)
                                            verticalAlignment: Text.AlignVCenter
                                            font.pointSize: Singletons.Config.baseFontSizePoint
                                        }
                                    }
                                    //------------------------------------------
                                    Rectangle {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Button {
                                            anchors.fill: parent
                                            anchors.margins: 10 * AppFramework.displayScaleFactor
                                            background: Rectangle {
                                                anchors.fill: parent
                                                color: Singletons.Config.buttonStates(control, "major")
                                                radius: app.info.properties.mainButtonRadius
                                                border.width: control.enabled ? app.info.properties.mainButtonBorderWidth : 0
                                                border.color: app.info.properties.mainButtonBorderColor
                                            }


                                            Text {
                                                color: app.info.properties.mainButtonBorderColor
                                                anchors.centerIn: parent
                                                textFormat: Text.RichText
                                                text: qsTr("Download")
                                                font.pointSize: Singletons.Config.baseFontSizePoint
                                            }

                                            onClicked: {
                                                Qt.openUrlExternally(download_url)
                                            }
                                        }
                                    }
                                }
                            }
                            //--------------------------------------------------
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1 * AppFramework.displayScaleFactor
                                color: Singletons.Colors.subtleBackground
                            }
                        }
                    }
                }
            }

            //--------------------------------------------------------------------------
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60 * AppFramework.displayScaleFactor

                RowLayout {
                    anchors.fill: parent
                    anchors.topMargin: 5 * AppFramework.displayScaleFactor
                    spacing: 0

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 150 * AppFramework.displayScaleFactor

                        Button {
                            id: closeDialogBtn
                            anchors.fill: parent
                            anchors.margins: 10 * AppFramework.displayScaleFactor
                            anchors.rightMargin: 0
                            enabled: true
                            background: Rectangle {
                                anchors.fill: parent
                                color: Singletons.Config.buttonStates(closeDialogBtn)
                                radius: app.info.properties.mainButtonRadius
                                border.width: closeDialogBtn.enabled ? app.info.properties.mainButtonBorderWidth : 0
                                border.color: app.info.properties.mainButtonBorderColor
                            }


                            Text {
                                color: app.info.properties.mainButtonFontColor
                                anchors.centerIn: parent
                                textFormat: Text.RichText
                                text: qsTr("Close")
                                font.pointSize: Singletons.Config.baseFontSizePoint
                            }

                            onClicked: {
                                updatesDialog.close()
                            }
                        }
                    }
                }
            }
            //--------------------------------------------------------------------------
        }
    }
}
