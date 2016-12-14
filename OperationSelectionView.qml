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
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
//------------------------------------------------------------------------------

Item {

    // PROPERTIES //////////////////////////////////////////////////////////////

    property Config config

    // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////////

    Component.onCompleted: {
        appMetrics.startSession();
    }

    //--------------------------------------------------------------------------

    Stack.onStatusChanged: {

        if(Stack.status === Stack.Deactivating){
            mainView.appToolBar.toolBarTitleLabel = "";
        }

        if(Stack.status === Stack.Activating){
            mainView.appToolBar.enabled = true;
            mainView.appToolBar.backButtonEnabled = false;
            mainView.appToolBar.backButtonVisible = false;
            mainView.appToolBar.historyButtonEnabled = true;
            mainView.appToolBar.toolBarTitleLabel = qsTr("Select an Operation")
        }
    }

    // UI //////////////////////////////////////////////////////////////////////

    Rectangle {
        id: mainSection
        anchors.fill: parent
        color: "#fff"

        Rectangle {
            id: buttonContainer
            anchors.centerIn: parent
            width: 710 * AppFramework.displayScaleFactor
            height: 230 * AppFramework.displayScaleFactor
            color:  "white"

            RowLayout {
                anchors.fill: parent
                spacing: 10 * AppFramework.displayScaleFactor

                // Button 1 ----------------------------------------------------

                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 230 * AppFramework.displayScaleFactor
                    color: app.info.properties.mainButtonBackgroundColor

                    Button {
                        id: uploadLocalTPKBtn
                        anchors.fill: parent

                        style: ButtonStyle {
                            background: Rectangle {
                                anchors.fill: parent
                                color: config.buttonStates(control, "major")
                                border.width: (control.enabled) ? app.info.properties.mainButtonBorderWidth : 0
                                border.color: app.info.properties.mainButtonBorderColor
                                radius: app.info.properties.mainButtonRadius
                            }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20 * AppFramework.displayScaleFactor
                                color: "transparent"
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                Image {
                                    id: uploadTPKIcon
                                    source: "images/upload_tpk.png"
                                    height: parent.height
                                    anchors.centerIn: parent
                                    fillMode: Image.PreserveAspectFit
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 25 * AppFramework.displayScaleFactor
                                Layout.topMargin: 15  * AppFramework.displayScaleFactor
                                color: "transparent"
                                Text {
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: app.info.properties.mainButtonBorderColor
                                    textFormat: Text.RichText
                                    text: qsTr("UPLOAD")
                                    font.pointSize: config.largeFontSizePoint * .8
                                    font.family: notoRegular.name
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20 * AppFramework.displayScaleFactor
                                color: "transparent"
                                Text {
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignTop
                                    color:app.info.properties.mainButtonBorderColor// app.info.properties.mainButtonFontColor
                                    textFormat: Text.RichText
                                    text: qsTr("Local Tile Package")
                                    font.pointSize: config.baseFontSizePoint
                                    font.family: notoRegular.name
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20 * AppFramework.displayScaleFactor
                                color: "transparent"
                            }
                        }

                        onClicked: {
                            mainStackView.push(utpkv);
                        }
                    }
                }

                // Button 2 ----------------------------------------------------

                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 230 * AppFramework.displayScaleFactor
                    color: app.info.properties.mainButtonBackgroundColor

                    Button {
                        id: createNewTPKBtn
                        anchors.fill: parent

                        style: ButtonStyle {
                            background: Rectangle {
                                anchors.fill: parent
                                color: config.buttonStates(control, "major")
                                border.width: (control.enabled) ? app.info.properties.mainButtonBorderWidth : 0
                                border.color: app.info.properties.mainButtonBorderColor
                                radius: app.info.properties.mainButtonRadius
                            }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20 * AppFramework.displayScaleFactor
                                color: "transparent"
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                Image {
                                    id: createNewTPKIcon
                                    source: "images/create_tpk.png"
                                    height: parent.height
                                    anchors.centerIn: parent
                                    fillMode: Image.PreserveAspectFit
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 25 * AppFramework.displayScaleFactor
                                Layout.topMargin: 15  * AppFramework.displayScaleFactor
                                color: "transparent"
                                Text {
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: app.info.properties.mainButtonBorderColor// app.info.properties.mainButtonFontColor
                                    textFormat: Text.RichText
                                    text: qsTr("CREATE")
                                    font.pointSize: config.largeFontSizePoint * .8
                                    font.family: notoRegular.name
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20 * AppFramework.displayScaleFactor
                                color: "transparent"
                                Text {
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignTop
                                    color: app.info.properties.mainButtonBorderColor // app.info.properties.mainButtonFontColor
                                    textFormat: Text.RichText
                                    text: qsTr("New Tile Package")
                                    font.pointSize: config.baseFontSizePoint
                                    font.family: notoRegular.name
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20 * AppFramework.displayScaleFactor
                                color: "transparent"
                            }
                        }

                        onClicked: {
                            mainStackView.push(asv);
                        }
                    }
                }

                // Button 3 ----------------------------------------------------

                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 230 * AppFramework.displayScaleFactor
                    color: app.info.properties.mainButtonBackgroundColor

                    Button {
                        id: browseOrgTpkBtn
                        anchors.fill: parent

                        style: ButtonStyle {
                            background: Rectangle {
                                anchors.fill: parent
                                color: config.buttonStates(control, "major")
                                border.width: (control.enabled) ? app.info.properties.mainButtonBorderWidth : 0
                                border.color: app.info.properties.mainButtonBorderColor
                                radius: app.info.properties.mainButtonRadius
                            }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20 * AppFramework.displayScaleFactor
                                color: "transparent"
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                Image {
                                    id: browseOrgTpkIcon
                                    source: "images/browse_tpks.png"
                                    anchors.centerIn: parent
                                    height: parent.height
                                    fillMode: Image.PreserveAspectFit
                                }
                             }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 25 * AppFramework.displayScaleFactor
                                Layout.topMargin: 15 * AppFramework.displayScaleFactor
                                color: "transparent"
                                Text {
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color:app.info.properties.mainButtonBorderColor // app.info.properties.mainButtonFontColor
                                    textFormat: Text.RichText
                                    text: qsTr("BROWSE")
                                    font.pointSize: config.largeFontSizePoint * .8
                                    font.family: notoRegular.name
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20 * AppFramework.displayScaleFactor
                                color: "transparent"
                                Text {
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignTop
                                    color: app.info.properties.mainButtonBorderColor // app.info.properties.mainButtonFontColor
                                    textFormat: Text.RichText
                                    text: qsTr("Organization Tile Packages")
                                    font.pointSize: config.baseFontSizePoint
                                    font.family: notoRegular.name
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20 * AppFramework.displayScaleFactor
                                color: "transparent"
                            }
                        }

                        onClicked: {
                            mainStackView.push(btpkv);
                        }
                    }
                }
            }
        }
    }

    // END /////////////////////////////////////////////////////////////////////
}
