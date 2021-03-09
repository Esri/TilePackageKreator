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
import QtQuick.Dialogs 1.3
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
//------------------------------------------------------------------------------
import "../Portal"
//------------------------------------------------------------------------------

Item {

    id: tpkUpdate

    // PROPERTIES //////////////////////////////////////////////////////////////

    property Portal portal

    property bool active

    signal updated()
    signal shared(string itemId)
    signal error(string err)
    signal cancelled(string response)

    // METHODS /////////////////////////////////////////////////////////////////

    function update(itemId, params){

        active = true;

        var itemInfo = {};

        for(var p in params){
            itemInfo[p] = params[p];
        }

        updateRequest.itemId = itemId;
        updateRequest.requestType = "update"
        updateRequest.send(itemInfo);
    }

    //--------------------------------------------------------------------------

    function share(itemId, param /* "org" || "everyone" || "groups" */){

        active = true;

        var itemInfo = {
            "f": "pjson",
            "token": portal.token
        };

        itemInfo[param] = true;

        //itemInfo["token"] = portal.token;
        //itemInfo.f = "pjson";
        //itemInfo["User-Agent"] = app.userAgent;

        updateRequest.itemId = itemId;
        updateRequest.requestType = "share"
        updateRequest.send(itemInfo);
    }

    //--------------------------------------------------------------------------

    function cancel(){
        if(active){
            updateRequest.abort();
        }
    }

    // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////////

    onError: {
        console.log('TPKUpdate error');
        active = false;
    }

    onCancelled:{
        console.log('TPKUpdate cancelled');
        active = false;
    }

    onUpdated: {
        console.log('TPKUpdate updated');
        active = false;
    }

    onShared: {
        console.log("TPKUpdate > shared");
        active = false;
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    NetworkRequest {

        id: updateRequest

        property string itemId
        property string requestType
        property url userContentUrl: tpkUpdate.portal.restUrl + "/content/users/" + tpkUpdate.portal.username

        signal success();
        signal failed(var error)

        responseType: "json"
        method: "POST"
        headers.userAgent: tpkUpdate.portal.userAgent

        url: userContentUrl +  "/items/" + itemId + "/" + requestType

        ignoreSslErrors: tpkUpdate.portal && tpkUpdate.portal.ignoreSslErrors

        headers {
            referrer: tpkUpdate.portal.portalUrl
        }

        onReadyStateChanged: {

            if (readyState === NetworkRequest.ReadyStateComplete) {

                if (status === 200) {
                     if (response.error) {
                        console.log('update error');
                        tpkUpdate.error(response.error)
                    }
                    else {
                         console.log('update success');

                        tpkUpdate.shared(this.itemId);
                    }
                }
                else {
                    if(status !== 0){
                        tpkUpdate.error("status is %1".arg(status.toString()));
                    }
                }
            }
        }

        onErrorTextChanged: {
            //if(errorText.indexOf("Operation canceled") > -1){
                //tpkUpdate.failed({"code":0, "message": errorText});
            //}
        }

    }

    // END /////////////////////////////////////////////////////////////////////
}
