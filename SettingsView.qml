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
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
//------------------------------------------------------------------------------
import "singletons" as Singletons
import "Controls" as Controls
//------------------------------------------------------------------------------

Item {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: settingsView

    // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////////

    StackView.onActivating: {
        app.settingsChanged = false;
        mainView.appToolBar.enabled = true;
        mainView.appToolBar.settingsButtonEnabled = false;
        mainView.appToolBar.historyButtonEnabled = true;
        mainView.appToolBar.backButtonEnabled = true;
        mainView.appToolBar.backButtonVisible = true;
        mainView.appToolBar.toolBarTitleLabel = qsTr("Settings");
    }

    // UI //////////////////////////////////////////////////////////////////////

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: sf(10)
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: sf(30)
            Controls.StyledCheckBox {
                anchors.fill: parent
                checked: app.allowAllLevels
                label: Singletons.Strings.enableAllZoomLevels
                onCheckedChanged: {
                    app.allowAllLevels = checked;
                }
            }
        }

        Rectangle {
            Layout.preferredHeight: sf(1)
            Layout.fillWidth: true
            Layout.topMargin: sf(20)
            Layout.bottomMargin: sf(20)
            color: Singletons.Colors.darkGray
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: sf(50)
            Controls.StyledCheckBox {
                id: timeOutCheckBox
                anchors.fill: parent
                checked: app.timeoutNonResponsiveServices
                label: Singletons.Strings.timeOutNonResponsive
                onCheckedChanged: {
                    app.timeoutNonResponsiveServices = checked;
                }
            }
        }

        Item {
            Layout.preferredWidth: parent.width * .7
            Layout.preferredHeight: sf(30)
            Layout.topMargin: sf(20)
            visible: app.timeoutNonResponsiveServices

            RowLayout {
                anchors.fill: parent
                spacing: sf(10)
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    RowLayout {
                        anchors.fill: parent
                        spacing: sf(8)
                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: contentWidth
                            text: Singletons.Strings.timeOutAfter
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.Wrap
                        }
                        Controls.StyledSlider {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            from: 3
                            to: 30
                            stepSize: 1
                            value: app.timeoutValue
                            snapMode: Slider.SnapAlways
                            onValueChanged: {
                                app.timeoutValue = value;
                            }
                        }
                        Text {
                            Layout.fillHeight: true
                            Layout.preferredWidth: contentWidth
                            verticalAlignment: Text.AlignVCenter
                            text: Singletons.Strings.xSeconds.arg(app.timeoutValue)
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.preferredHeight: sf(1)
            Layout.fillWidth: true
            Layout.topMargin: sf(20)
            Layout.bottomMargin: sf(20)
            color: Singletons.Colors.darkGray
        }

        Item {
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: sf(160)

            ColumnLayout {
                anchors.fill: parent
                spacing: sf(8)
                Text {
                    Layout.fillHeight: true
                    Layout.preferredWidth: contentWidth
                    text: qsTr("Search Query for Tile Services (see <a href='https://developers.arcgis.com/rest/users-groups-and-items/search.htm'>Search API</a> for more details)")
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    color: Singletons.Colors.formElementFontColor
                    textFormat: Text.RichText
                    font {
                        family: defaultFontFamily
                        pointSize: Singletons.Config.baseFontSizePoint
                    }
                    onLinkActivated: {
                        Qt.openUrlExternally(link);
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: sf(40)
                    Controls.StyledTextField {
                        id: searchQueryTextField
                        anchors.fill: parent
                        text: app.settings.value(Singletons.Constants.kSearchQueryString)
                        Component.onCompleted: {
                            cursorPosition = 0;
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: sf(50)
                    Controls.StyledCheckBox {
                        id: includeCurrentUserSearchQuery
                        anchors.fill: parent
                        checked: app.includeCurrentUserInSearch
                        label: qsTr("Include Map and Image Services owned by %1 in query?<br> <small><em>%2</em></small>".arg(portal.username).arg(app.currentUserSearchQuery))
                        fontSizeMultiplier: .8
                        onCheckedChanged: {
                            app.includeCurrentUserInSearch = checked;
                        }
                    }
                }

                RowLayout {
                    spacing: sf(5)
                    Layout.preferredHeight: sf(40)
                    Layout.fillWidth: true

                    Item {
                        Layout.preferredWidth: sf(140)
                        Layout.fillHeight: true
                        Button {
                            anchors.fill: parent

                            background: Rectangle {
                                anchors.fill: parent
                                color: Singletons.Config.buttonStates(parent, "clear")
                                radius: app.info.properties.mainButtonRadius
                                border.width: 0
                                border.color: app.info.properties.mainButtonBorderColor
                            }
                            Text {
                                color: app.info.properties.mainButtonBorderColor
                                anchors.centerIn: parent
                                textFormat: Text.RichText
                                text: qsTr("Reset to default")
                                font.pointSize: Singletons.Config.baseFontSizePoint
                                font.family: defaultFontFamily
                            }
                            onClicked: {
                                searchQueryTextField.text = app.defaultSearchQuery;
                                includeCurrentUserSearchQuery.checked = true;
                                updateButton.clicked();
                            }
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                    }

                    Item {
                        Layout.preferredWidth: sf(100)
                        Layout.fillHeight: true
                        Button {
                            id: updateButton
                            anchors.fill: parent
                            enabled: searchQueryTextField.text > ""
                            background: Rectangle {
                                anchors.fill: parent
                                color: Singletons.Config.buttonStates(parent)
                                radius: app.info.properties.mainButtonRadius
                                border.width: parent.enabled ? app.info.properties.mainButtonBorderWidth : 0
                                border.color: app.info.properties.mainButtonBorderColor
                            }
                            Text {
                                color: app.info.properties.mainButtonFontColor
                                anchors.centerIn: parent
                                textFormat: Text.RichText
                                text: qsTr("Update")
                                font.pointSize: Singletons.Config.baseFontSizePoint
                                font.family: defaultFontFamily
                            }
                            onClicked: {
                                app.servicesSearchQuery = searchQueryTextField.text;
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.preferredHeight: sf(1)
            Layout.fillWidth: true
            Layout.topMargin: sf(20)
            Layout.bottomMargin: sf(20)
            color: Singletons.Colors.darkGray
        }

        //----------------------------------------------------------------------

//        Item {
//            Layout.fillWidth: true
//            Layout.preferredHeight: sf(30)
//            Controls.StyledCheckBox {
//                anchors.fill: parent
//                label: Singletons.Strings.allowNonWebMerctorServices
//                checked: app.allowNonWebMercatorServices
//                onCheckedChanged: {
//                    app.allowNonWebMercatorServices = checked;
//                }
//            }
//        }

        //----------------------------------------------------------------------

        Item {
            Layout.fillHeight: true
        }

        //----------------------------------------------------------------------

    }

    // END /////////////////////////////////////////////////////////////////////
}
