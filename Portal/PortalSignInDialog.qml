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

import QtQuick 2.15
import QtQuick.Controls 1.4
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.2

import ArcGIS.AppFramework 1.0

//------------------------------------------------------------------------------

Dialog {
    id: dialog

    property Portal portal
    property Settings settings
    property string settingsGroup: "Portal"

    property alias bannerImage: signInView.bannerImage
    property alias bannerColor: signInView.bannerColor
    property alias bannerTextColor: signInView.bannerTextColor
    property alias backgroundColor: signInView.backgroundColor

    //modality: Qt.ApplicationModal

    title: signInView.title

    contentItem: Item {
        implicitWidth: Math.min(640 * AppFramework.displayScaleFactor, Screen.desktopAvailableWidth * 0.95)
        implicitHeight: Math.min(480 * AppFramework.displayScaleFactor, Screen.desktopAvailableHeight * 0.95)

        PortalSignInView {
            id: signInView

            anchors.fill: parent

            portal: dialog.portal
            settings: dialog.settings
            settingsGroup: dialog.settingsGroup
            dialogStyle: true

            onAccepted: {
                dialog.accepted();
                close();
            }

            onRejected: {
                dialog.rejected();
                close();
            }
        }
    }

    //--------------------------------------------------------------------------
}
