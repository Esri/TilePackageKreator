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

Item {

    id: tpkGeometryHelper

    // PROPERTIES //////////////////////////////////////////////////////////////

    readonly property url esriGeometryServiceUrl: "http://tasks.arcgisonline.com/ArcGIS/rest/services/Geometry/GeometryServer"
    readonly property url areasAndLengthsUrl: esriGeometryServiceUrl + "/areasAndLengths"
    readonly property url bufferUrl: esriGeometryServiceUrl + "/buffer"
    readonly property url projectUrl: esriGeometryServiceUrl + "/project"

    property bool active

    signal complete(var geometries)
    signal error(var err)
    signal success()

    // METHODS /////////////////////////////////////////////////////////////////

    function buffer(g, sr, bufferDistance){

        var requestInfo = {
            "f": "pjson",
            "geometries": JSON.stringify(g),
            "inSR": sr,
            "outSR": sr,
            "bufferSR": 3857,
            "unit": 9001,
            "distances": bufferDistance,
            "unionResults": true
        }

        console.log(JSON.stringify(requestInfo));

        geometryNetworkRequest.url = bufferUrl;
        geometryNetworkRequest.send(requestInfo);
        active = true;
    }

    function project(g, sr){
        var requestInfo = {
            "f": "json"
        }
    }

    function cancel(){
        geometryNetworkRequest.abort();
    }

    // SIGNAL IMPLEMENTATION ///////////////////////////////////////////////////

    onComplete: {
        //console.log(JSON.stringify(geometries));
    }

    onError: {

    }

    onSuccess: {

    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    NetworkRequest {

        id: geometryNetworkRequest

        responseType: "json"

        method: "POST"

        onReadyStateChanged: {

            if (readyState === NetworkRequest.ReadyStateComplete)
            {
                tpkGeometryHelper.active = false;

                if (status === 200) {
                    //console.log(JSON.stringify(response));
                   // var responseJson = JSON.parse(response);

                    if(response.hasOwnProperty("geometries")){
                        tpkGeometryHelper.complete(response);
                    }
                    else{
                        console.log('no geometry or error');
                        tpkGeometryHelper.error({"message": "no geometry returned"});
                    }
                }
            }
            else{
            }
        }
    }

    // END /////////////////////////////////////////////////////////////////////
}
