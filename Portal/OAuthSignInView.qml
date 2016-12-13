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

import QtQuick 2.5
import QtQuick.Controls 1.4

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.WebView 1.0

import "../Controls"

//------------------------------------------------------------------------------

Item {
    property string authorizationUrl
    property bool hideCancel: false

    signal accepted(string authorizationCode)
    signal rejected()

    onAuthorizationUrlChanged: {
        //console.log("oauth auth url changed", authorizationUrl);
        //webView.url = authorizationUrl + "&hidecancel=" + hideCancel.toString();
        //webView.reload();
    }

    //--------------------------------------------------------------------------

    WebView {
        id: webView

        anchors.fill: parent

        url: authorizationUrl + "&hidecancel=" + hideCancel.toString()

        onLoadingChanged: {
            //console.log("webView.title", title);

            if (title.indexOf("SUCCESS code=") > -1) {
                var authorizationCode = title.replace("SUCCESS code=", "");
                accepted(authorizationCode);
            } else if (title === "Denied error=access_denied") { // Cancel pressed
                rejected();
            }
        }
    }

    //--------------------------------------------------------------------------

    ColorBusyIndicator {
        anchors.centerIn: parent

        backgroundColor: signInView.bannerColor
        running: webView.loading
    }

    ProgressBar {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        height: 5 * AppFramework.displayScaleFactor
        visible: webView.loading
        value: webView.loadProgress
        minimumValue: 0
        maximumValue: 100
    }

    //--------------------------------------------------------------------------
}
