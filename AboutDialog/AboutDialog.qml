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
import QtQuick.Dialogs 1.2

import ArcGIS.AppFramework 1.0

Dialog {
    property url icon: app.folder.fileUrl("appicon.png")
    property string termsOfUseUrl: "http://www.esri.com/legal/software-license"

    width: 700 * AppFramework.displayScaleFactor
    standardButtons: StandardButton.Close
    //    modality: Qt.ApplicationModal

    title: qsTr("About") + " " + app.info.title

    //--------------------------------------------------------------------------

    ColumnLayout {
        width: parent ? parent.width : 100
        height: 550 * AppFramework.displayScaleFactor
        spacing: 8 * AppFramework.displayScaleFactor

        RowLayout {
            Layout.fillWidth: true

            Image {
                Layout.preferredWidth: 64 * AppFramework.displayScaleFactor
                Layout.preferredHeight: 64 * AppFramework.displayScaleFactor

                source: icon
                fillMode: Image.PreserveAspectFit
            }

            Text {
                Layout.fillWidth: true

                text: qsTr("About %1").arg(app.info.title)
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.family: defaultFontFamily
                font {
                    pointSize: 22
                    bold: true
                }
            }
        }

        AboutSeparator {
        }

        AboutText {
            text: qsTr("Product Information")
            font {
                pointSize: 15
                bold: true
            }
        }

        AboutText {
            text: qsTr("%1 <b>%2</b>").arg(app.info.title).arg(app.info.version);
            font {
                pointSize: 16
            }
        }

        AboutText {
            text: "Copyright © 2018 Esri Inc. All Rights Reserved"
        }

        AboutText {
            text: qsTr("<a href='%1'>View the Terms of Use</a>").arg(termsOfUseUrl)
        }

        AboutText {
            text: qsTr("This work is protected by copyright law and international treaties. Unauthorized reproduction or distribution of this program, or any portion of it, may result in severe civil and criminal penalties and will be prosecuted to the maximum extent possible under the law.")
        }

        Item {
            Layout.fillHeight: true
        }

        AboutSeparator {
        }

        ColumnLayout {
            Layout.fillWidth: true

            spacing: 3 * AppFramework.displayScaleFactor

            AboutLabelValue {
                label: qsTr("AppFramework version:")
                value: AppFramework.version
            }

            AboutLabelValue {
                label: qsTr("Qt version:")
                value: AppFramework.qtVersion
            }

            AboutLabelValue {
                label: qsTr("Operating system version:")
                value: AppFramework.osVersion
            }

            AboutLabelValue {
                label: qsTr("Kernel version:")
                value: AppFramework.kernelVersion
            }

            AboutLabelValue {
                label: qsTr("SSL library version:")
                value: AppFramework.sslLibraryVersion
            }
        }

        AboutSeparator {
            color: "#20000000"
        }

        ColumnLayout {
            Layout.fillWidth: true

            spacing: 3 * AppFramework.displayScaleFactor

            AboutLabelValue {
                label: qsTr("User home path:")
                value: AppFramework.userHomePath
                valueType: 1
            }
        }
    }

    //--------------------------------------------------------------------------
}
