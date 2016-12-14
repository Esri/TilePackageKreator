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

DeepLinkingRequest {

    /* This component adds application specific parameters to the DeepLinkingRequest component */

    // PROPERTIES //////////////////////////////////////////////////////////////

    property var token: null
    property var refreshToken: null
    property var handoffClientId: null
    property var tokenExpiry: null
    property var username: null
    property var canPublish: null

    // create related
    property var tileService: null
    property var center: null
    property var zoomLevel: null
    property var saveToPath: null

    // upload related
    property var filePath: null

    // return parameters
    property bool isShared
    property bool isOnline
    property string itemId
    property var localPath

    // SIGNALS /////////////////////////////////////////////////////////////////


    // METHODS /////////////////////////////////////////////////////////////////

    function parseParameters(){

        for(var x in parameters){
            console.log("parameter %1 = %2".arg(x).arg(parameters[x]));
        }

        if(parameters.hasOwnProperty("token")){
            if(parameters.token !== "" || parameters.token !== null){
                token = parameters.token;
            }
        }

        if(parameters.hasOwnProperty("refreshToken")){
            if(parameters.refreshToken !== "" || parameters.refreshToken !== null){
                refreshToken = parameters.refreshToken;
            }
        }

        if(parameters.hasOwnProperty("handoffClientId")){
            if(parameters.handoffClientId !== "" || parameters.handoffClientId !== null){
                handoffClientId = parameters.handoffClientId;
            }
        }

        if(parameters.hasOwnProperty("tokenExpiry")){
            if(parameters.tokenExpiry !== "" || parameters.tokenExpiry !== null){
                tokenExpiry =  new Date(parameters.tokenExpiry);
            }
        }

        if(parameters.hasOwnProperty("username")){
            if(parameters.username !== "" || parameters.username !== null){
                username = parameters.username;
            }
        }
        if(parameters.hasOwnProperty("canPublish")){
            if(parameters.canPublish !== "" || parameters.canPublish !== null){
                canPublish = parameters.canPublish;
            }
        }

        if(parameters.hasOwnProperty("tileService")){
            if(parameters.tileService !== "" || parameters.tileService !== null){
                tileService = parameters.tileService;
            }
        }

        if(parameters.hasOwnProperty("center")){
            if(parameters.center !== "" || parameters.center !== null){
                center = _parseCoordinates(parameters.center);
            }
        }

        if(parameters.hasOwnProperty("zoomLevel")){
            if(parameters.zoomLevel !== "" || parameters.zoomLevel !== null){
                zoomLevel = parameters.zoomLevel;
            }
        }

        if(parameters.hasOwnProperty("saveToPath")){
            if(parameters.saveToPath !== "" || parameters.saveToPath !== null){
                saveToPath = decodeURI(parameters.saveToPath);
            }
        }

        if(parameters.hasOwnProperty("filePath")){
            if(parameters.filePath !== "" || parameters.filePath !== null){
                filePath = decodeURI(parameters.filePath);
            }
        }


    }

    //--------------------------------------------------------------------------

    function _parseCoordinates(inCoord){

        var coords = inCoord.split(',');
        return {"lat": coords[0].trim(), "long": coords[1].trim()};

    }

    // END /////////////////////////////////////////////////////////////////////
}
