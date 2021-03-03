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

//------------------------------------------------------------------------------

Item {
    property Settings settings
    property string settingsGroup: "Portal"
    property alias model: portalsModel

    
    ListModel {
        id: portalsModel
        
        ListElement {
            url: "https://www.arcgis.com"
            name: "ArcGIS Online"
            ignoreSslErrors: false
            isPortal: false
            supportsOAuth: true
        }
    }

    //--------------------------------------------------------------------------

    function read() {
        if (!settings) {
            return;
        }

        var portalsList;

        try {
            portalsList = JSON.parse(settings.value(settingsGroup + "/portals", ""));
        } catch (err) {
            console.log("Empty portal list:", err);
        }

        if (!Array.isArray(portalsList)) {
            portalsList = [];

            portalsList.push({
                                 url: "https://www.arcgis.com",
                                 name: "ArcGIS Online",
                                 ignoreSslErrors: false,
                                 isPortal: false,
                                 supportsOAuth: true
                             });
        }

        portalsModel.clear();

        portalsList.forEach(function(element) {
            if (!element.hasOwnProperty("ignoreSslErrors")) {
                element.ignoreSslErrors = false;
            }

            if (!element.hasOwnProperty("isPortal")) {
                element.isPortal = false;
            }

            if (!element.hasOwnProperty("supportsOAuth")) {
                element.supportsOAuth = true;
            }

            portalsModel.append(element);
        });
    }

    //--------------------------------------------------------------------------

    function write() {
        if (!settings) {
            return;
        }

        var portalsList = [];

        for (var i = 0; i < portalsModel.count; i++) {
            var element = portalsModel.get(i);

            console.log(JSON.stringify(element));

            var entry = {
                url: element.url,
                name: element.name,
                ignoreSslErrors: element.ignoreSslErrors,
                isPortal: element.isPortal,
                supportsOAuth: element.supportsOAuth
            };

            portalsList.push(entry);
        }

        settings.setValue(settingsGroup + "/portals", JSON.stringify(portalsList));
    }

    //--------------------------------------------------------------------------

    function append(portalItem) {
        portalsModel.append(portalItem);
        write();

        return portalsModel.count - 1;
    }

    function remove(index) {
        portalsModel.remove(index, 1);
        write();
    }

    //--------------------------------------------------------------------------

    function find(portalUrl) {
        for (var i = 0; i < portalsModel.count; i++) {
            var element = portalsModel.get(i);

            //console.log("find", element.url, portalUrl);

            if (element.url == portalUrl.toString()) {
                return i;
            }
        }

        return -1;
    }

    //--------------------------------------------------------------------------
}
