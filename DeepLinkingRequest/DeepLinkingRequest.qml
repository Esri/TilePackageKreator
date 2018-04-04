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

import QtQuick 2.5
import ArcGIS.AppFramework 1.0

QtObject {

    /* This component only supports x-callback-url schema */

    // PROPERTIES //////////////////////////////////////////////////////////////

    property string scheme: ""
    property string specification: ""
    property var parameters: null

    property var actions: null
    property string mainAction: ""
    property string secondaryAction: ""

    property string callingApplication: "Calling Application"
    property string successCallback: ""
    property string errorCallback: ""
    property string cancelCallback: ""

    property bool goodUrl: false

    readonly property string xCallbackIdentifier: "x-callback-url"

    // SIGNALS /////////////////////////////////////////////////////////////////

    onActionsChanged: {
        if (actions !== null) {
            mainAction = actions[0];
            secondaryAction = (actions.length > 1) ? actions[1] : "";
        }
    }

    // METHODS /////////////////////////////////////////////////////////////////

    function parseUrl(inUrl){

        var url = AppFramework.urlInfo(inUrl);

        parameters = url.queryParameters;
        scheme = (url.scheme !== "") ? url.scheme : "";
        specification = (url.host !== "") ? url.host : "";
        actions = (url.path !== "") ? resolveActionsFromPath(url.path) : null;

        // this url follows the x-callback specification
        if (specification === xCallbackIdentifier /* && actions !== null */) {

            if (parameters.hasOwnProperty("x-source")) {
                callingApplication = parameters["x-source"];
            }

            if (parameters.hasOwnProperty("x-success")) {
                successCallback = parameters["x-success"];
            }

            if (parameters.hasOwnProperty("x-error")) {
                errorCallback = parameters["x-error"];
            }

            if (parameters.hasOwnProperty("x-cancel")) {
                cancelCallback = parameters["x-cancel"];
            }

            goodUrl = true;

        }

        // this does not follow the x-callback-url schema and will be ignored
        else {
            goodUrl = false;
        }

        return goodUrl;

    }

    //--------------------------------------------------------------------------

    function resolveActionsFromPath(path){

        var splitPath = path.split("/");

        splitPath.shift(); // get rid of empty element before first /

        if (splitPath.length > 0) {
            return splitPath;
        }
        else {
            return null;
        }

    }

    //--------------------------------------------------------------------------

    function reset(){
        scheme = "";
        specification = "";
        parameters = null;
        actions = null;
        mainAction = "";
        secondaryAction = "";
        callingApplication = "Calling Application";
        successCallback = "";
        errorCallback = "";
        cancelCallback = "";
        goodUrl = false;
    }

    // END /////////////////////////////////////////////////////////////////////
}
