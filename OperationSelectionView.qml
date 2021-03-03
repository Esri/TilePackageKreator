/* Copyright 2017 Esri
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
//------------------------------------------------------------------------------
import "singletons" as Singletons

Item {

    // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////////

    Component.onCompleted: {
        appMetrics.startSession();
    }

    //--------------------------------------------------------------------------

    StackView.onActivating: {
        mainView.appToolBar.toolBarTitleLabel = Singletons.Strings.selectAnOperation;
        mainView.appToolBar.enabled = true;
        mainView.appToolBar.backButtonEnabled = false;
        mainView.appToolBar.backButtonVisible = false;
        mainView.appToolBar.historyButtonEnabled = true;
        mainView.appToolBar.settingsButtonEnabled = true;
    }

    // UI //////////////////////////////////////////////////////////////////////

    Rectangle {
        id: mainSection
        anchors.fill: parent
        color: "#fff"

        Rectangle {
            id: buttonContainer
            anchors.centerIn: parent
            width: sf(710)
            height: sf(230)
            color: "white"

            RowLayout {
                anchors.fill: parent
                spacing: sf(10)

                // Button 1 ----------------------------------------------------

                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: sf(230)
                    color: app.info.properties.mainButtonBackgroundColor

                    Button {
                        id: uploadLocalTPKBtn
                        anchors.fill: parent

                        background: Rectangle {
                            anchors.fill: parent
                            color: Singletons.Config.buttonStates(parent, "major")
                            border.width: parent.enabled ? app.info.properties.mainButtonBorderWidth : 0
                            border.color: app.info.properties.mainButtonBorderColor
                            radius: app.info.properties.mainButtonRadius
                            Accessible.ignored: true
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0
                            Accessible.ignored: true
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: sf(20)
                            }
                            Item {
                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                Image {
                                    id: uploadTPKIcon
                                    source: "images/upload_tpk.png"
                                    height: parent.height
                                    anchors.centerIn: parent
                                    fillMode: Image.PreserveAspectFit
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: sf(25)
                                Layout.topMargin: sf(15)
                                Text {
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: app.info.properties.mainButtonBorderColor
                                    textFormat: Text.RichText
                                    text: Singletons.Strings.upload
                                    font.pointSize: Singletons.Config.largeFontSizePoint * .8
                                    font.family: defaultFontFamily
                                    font.capitalization: Font.AllUppercase
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: sf(20)
                                Text {
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignTop
                                    color:app.info.properties.mainButtonBorderColor
                                    textFormat: Text.RichText
                                    text: Singletons.Strings.localTilePackage
                                    font.pointSize: Singletons.Config.baseFontSizePoint
                                    font.family: defaultFontFamily
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: sf(20)
                            }
                        }

                        onClicked: {
                            mainStackView.push(utpkv);
                        }

                        Accessible.role: Accessible.Button
                        Accessible.name: Singletons.Strings.uploadTilePackage
                        Accessible.onPressAction: {
                            if(enabled && visible){
                                clicked();
                            }
                        }
                    }
                }

                // Button 2 ----------------------------------------------------

                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: sf(230)
                    color: app.info.properties.mainButtonBackgroundColor

                    Button {
                        id: createNewTPKBtn
                        anchors.fill: parent

                        background: Rectangle {
                            anchors.fill: parent
                            color: Singletons.Config.buttonStates(parent, "major")
                            border.width: parent.enabled ? app.info.properties.mainButtonBorderWidth : 0
                            border.color: app.info.properties.mainButtonBorderColor
                            radius: app.info.properties.mainButtonRadius
                            Accessible.ignored: true
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0
                            Accessible.ignored: true
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: sf(20)
                            }
                            Item {
                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                Image {
                                    id: createNewTPKIcon
                                    source: "images/create_tpk.png"
                                    height: parent.height
                                    anchors.centerIn: parent
                                    fillMode: Image.PreserveAspectFit
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: sf(25)
                                Layout.topMargin: sf(15)
                                Text {
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: app.info.properties.mainButtonBorderColor
                                    textFormat: Text.RichText
                                    text: Singletons.Strings.create
                                    font.pointSize: Singletons.Config.largeFontSizePoint * .8
                                    font.family: defaultFontFamily
                                    font.capitalization: Font.AllUppercase
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: sf(20)
                                Text {
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignTop
                                    color: app.info.properties.mainButtonBorderColor
                                    textFormat: Text.RichText
                                    text: Singletons.Strings.newTilePackage
                                    font.pointSize: Singletons.Config.baseFontSizePoint
                                    font.family: defaultFontFamily
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: sf(20)
                            }
                        }

                        onClicked: {
                            mainStackView.push(asv);
                        }

                        Accessible.role: Accessible.Button
                        Accessible.name: Singletons.Strings.createNewTilePackage
                        Accessible.onPressAction: {
                            if(enabled && visible){
                                clicked();
                            }
                        }
                    }
                }

                // Button 3 ----------------------------------------------------

                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: sf(230)
                    color: app.info.properties.mainButtonBackgroundColor

                    Button {
                        id: browseOrgTpkBtn
                        anchors.fill: parent

                        background: Rectangle {
                            anchors.fill: parent
                            color: Singletons.Config.buttonStates(parent, "major")
                            border.width: parent.enabled ? app.info.properties.mainButtonBorderWidth : 0
                            border.color: app.info.properties.mainButtonBorderColor
                            radius: app.info.properties.mainButtonRadius
                            Accessible.ignored: true
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0
                            Accessible.ignored: true
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: sf(20)
                            }
                            Item {
                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                Image {
                                    id: browseOrgTpkIcon
                                    source: "images/browse_tpks.png"
                                    anchors.centerIn: parent
                                    height: parent.height
                                    fillMode: Image.PreserveAspectFit
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: sf(25)
                                Layout.topMargin: sf(15)
                                Text {
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: app.info.properties.mainButtonBorderColor
                                    textFormat: Text.RichText
                                    text: Singletons.Strings.browse
                                    font.pointSize: Singletons.Config.largeFontSizePoint * .8
                                    font.family: defaultFontFamily
                                    font.capitalization: Font.AllUppercase
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: sf(20)
                                Text {
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignTop
                                    color: app.info.properties.mainButtonBorderColor
                                    textFormat: Text.RichText
                                    text: Singletons.Strings.organizationTilePackages
                                    font.pointSize: Singletons.Config.baseFontSizePoint
                                    font.family: defaultFontFamily
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: sf(20)
                            }
                        }

                        onClicked: {
                            mainStackView.push(btpkv);
                        }

                        Accessible.role: Accessible.Button
                        Accessible.name: Singletons.Strings.browseOrgTilePackages
                        Accessible.onPressAction: {
                            if(enabled && visible){
                                clicked();
                            }
                        }
                    }
                }
            }
        }
    }

    // END /////////////////////////////////////////////////////////////////////
}
