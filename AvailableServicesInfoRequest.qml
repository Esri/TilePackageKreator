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
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
//------------------------------------------------------------------------------
import "Portal"
//------------------------------------------------------------------------------

Item {

    id: availableServiceInfoRequest

    property Portal portal
    property int tileIndex
    property string serviceUrl
    property bool useToken: true
    property bool useTimeout: false
    property int timeoutInterval: 30

    signal complete(var data)

    onComplete:  {
        if (timeoutTimer.running) {
            timeoutTimer.stop();
        }
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    NetworkRequest {

        id: serviceRequest

        responseType: "json"

        method: "GET"

        url: serviceUrl + "?f=json" + (portal.signedIn ? "&token=" + portal.token : "")

        headers {
            userAgent: portal.userAgent
        }

        // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////

        onReadyStateChanged: {

            //console.log("url: ", url);
            //console.log(readyState);

            if (readyState === NetworkRequest.ReadyStateComplete) {

                //console.log("url: ", url);
                //console.log(responseText);

                if (status === 200) {
                    try {

                        var serviceJson = JSON.parse(responseText);

                        if (serviceJson.hasOwnProperty("error")) {
                            if (serviceJson.error.hasOwnProperty("message")) {
                                if (serviceJson.error.message === "Invalid Token") {
                                    /*
                                    If token is invalid, the service may be unsecured so try again without token.

                                    If a token is required for a service, the message would be "Token Required"
                                    Therefore to switch to a unsecured check first paradigm, just swap the message check in
                                    this if clause to "Token Required" and then add the token to the url in this
                                    if clause and remove token from the object url parameter ~ line 26,
                                    set useToken to be false ~ line 18, and set useToken = true in this if clause.
                                    */
                                    availableServiceInfoRequest.useToken = false;
                                    serviceRequest.url = serviceUrl + "?f=json";
                                    availableServiceInfoRequest.sendRequest(); //.send();

                                }
                                else {
                                    // BAD: 200 Status, Good Json, But Json has error property
                                    availableServiceInfoRequest.complete({
                                                    "tileIndex": tileIndex,
                                                    "keep": false,
                                                    "serviceInfo": null
                                                    });
                                }
                            }
                        }
                        else {
                            if (_exportTilesAllowed(serviceJson)) {
                                // GOOD: 200 Status, Good Json and I allow exporting tiles.
                                availableServiceInfoRequest.complete({
                                                "tileIndex": tileIndex,
                                                "keep": true,
                                                "serviceInfo": responseText,
                                                "useToken": useToken
                                            });
                            }
                            else {
                                // BAD: 200 Status, Good Json EXPORTING NOT ALLOWED.
                                availableServiceInfoRequest.complete({
                                                "tileIndex": tileIndex,
                                                "keep": false,
                                                "serviceInfo": null
                                            });
                            }
                        }
                    }
                    catch(e) {
                        // BAD: 200 Status, Bad Json or didn't return Json
                        availableServiceInfoRequest.complete({
                                        "tileIndex": tileIndex,
                                        "keep": false,
                                        "serviceInfo": null
                                    });
                    }
                }
                else {
                    // BAD: Status other than 200 so totally bad.
                    availableServiceInfoRequest.complete({
                                    "tileIndex": tileIndex,
                                    "keep": false,
                                    "serviceInfo": null
                                });
                }
            }
        }
    }

    Timer {
        id: timeoutTimer
        //interval: timeoutInterval * 1000
        running: false
        repeat: false
        onTriggered: {
            availableServiceInfoRequest.complete({
                            "tileIndex": tileIndex,
                            "keep": false,
                            "serviceInfo": null
                        });
            serviceRequest.abort();
        }
    }

    // METHODS /////////////////////////////////////////////////////////////////

    function sendRequest() {
        serviceRequest.send();
        if (useTimeout) {
            timeoutTimer.interval = timeoutInterval * 1000;
            timeoutTimer.start();
        }
    }

    //--------------------------------------------------------------------------

    function _exportTilesAllowed(serviceInfo) {

        if (serviceInfo.hasOwnProperty("exportTilesAllowed")) {
            if (serviceInfo.exportTilesAllowed === false) {
                return false;
            }
            else {
                return true;
            }
        }
        else {
            return false;
        }
    }

    // END /////////////////////////////////////////////////////////////////////
}
