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

import ArcGIS.AppFramework 1.0

NetworkRequest {
    id: request

    property Portal portal
    property bool trace: false
    property bool active

    signal success();
    signal failed(var error)

    responseType: "json"
    method: "POST"
    ignoreSslErrors: portal && portal.ignoreSslErrors

   //headers {
    //    referrer: portal.portalUrl
    //}

    // TODO : This is a work around for above crashing when portal changes

    onPortalChanged: {
        if (portal) {
            headers.referrer = portal.portalUrl.toString();
            console.log(portal.portalUrl.toString());
        }
    }

    onReadyStateChanged: {
        //console.log("portalRequest readyState", readyState);

        if (readyState === NetworkRequest.ReadyStateComplete){
           //console.log("portalRequest status", status, statusText, "responseText", responseText, "responsePath", responsePath);
            request.active = false;
            if (status === 200) {
                if (responsePath) {
                    //console.log("success");
                    success();
                } else {
                    if (response.error) {
                        //console.log("repoinse with error");
                        failed(response.error);
                    } else {
                        //console.log(response);
                        success();
                    }
                }
            } else {
                console.error("PortalRequest status:", status, statusText);
                if(status !== 0){
                    failed({ "code": status, "message": statusText });
                }

            }
        }
    }

    onErrorTextChanged: {
        console.error("portalRequest onErrorTextChanged:", url, "error", errorText);
        if(errorText.indexOf("Operation canceled") > -1){
            //failed({"code":0, "message": errorText});
        }
    }

    onFailed: {
        console.error("PortalRequest failed: url", url, "error", JSON.stringify(error, undefined, 2));
        console.log(error.message);
    }


    function sendRequest(formData) {
        if (!formData) {
            formData = {};
        }

        if(formData.hasOwnProperty("useToken")){
            console.log("useToken");
            if(formData.useToken === true){
                formData.token = portal.token;
            }
        }
        else{
            formData.token = portal.token;
        }

        if (responseType === "json") {
            formData.f = "pjson";
        }

        if (trace) {
            console.log("formData:", JSON.stringify(formData, undefined, 2));
        }

        console.log("formdata: "+ JSON.stringify(formData));

        request.active = true;

        headers.userAgent = portal.userAgent;
        send(formData);
    }
}
