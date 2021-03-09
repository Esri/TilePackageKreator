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
import ArcGIS.AppFramework.Sql 1.0
//--------------------------------------------------------------------------
import "Portal"
import "singletons" as Singletons

//--------------------------------------------------------------------------

Item {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: availableServicesModel

    property Portal portal
    property bool busy: false
    property int tileServiceCount: 0
    property int tileServiceSum: 0
    property var requests: []
    property alias getAvailableServices: tileServicesSearch
    property string searchQuery: !app.includeCurrentUserInSearch
                                 ? app.servicesSearchQuery
                                 : app.currentUserSearchQuery > ""
                                   ? app.servicesSearchQuery + " " + app.currentUserSearchQuery
                                   : app.servicesSearchQuery
    property SqlQueryModel userAddedServices
    property bool useTimeout: app.timeoutNonResponsiveServices
    property int timeoutInterval: app.timeoutValue

    property ListModel servicesListModel: ListModel {
        property var tilesToRemove: []
        function removeBadTiles(){
            tilesToRemove.sort(function(a, b) {
                return b - a;
              });

            for(var i = 0; i < tilesToRemove.length; i++){
                servicesListModel.remove(tilesToRemove[i]);
            }
            _getUserSavedTileServices();
            //availableServicesModel.modelComplete();


            tilesToRemove = [];
        }
    }

    signal servicesCountReady(int numberOfServices)
    signal modelComplete()
    signal failed(var error)
    signal serviceAdded()
    signal serviceNotAdded()


    function reset(){
        tileServiceCount = 0;
        tileServiceSum = 0;
        requests = [];
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    PortalSearch {

        id: tileServicesSearch

        portal: availableServicesModel.portal
        q: searchQuery
        sortField: "title"
        sortOrder: "asc"

        onSuccess: {
            response.results.forEach(function (result) {

                //console.log(JSON.stringify(result));

                try {
                    if (!result.description) {
                        result.description = "";
                    }

                    result.isArcgisTileService = result.url !== null ? _isArcgisTileService(result.url) : false;
                    result.isWebMercator = _isWebMercator(result.spatialReference);
                    result.serviceUrl = result.url;
                    result.useTokenToAccess = true;
                    result.serviceInfo = {};

                    //----------------------------------------------------------

                    var component = Qt.createComponent("AvailableServicesInfoRequest.qml");

                    if (component.status === Component.Ready) {
                        var thisRequest = component.createObject(parent,
                                                                 {
                                                                     portal:availableServicesModel.portal,
                                                                     tileIndex: tileServiceCount,
                                                                     serviceUrl: result.url,
                                                                     useTimeout: availableServicesModel.useTimeout,
                                                                     timeoutInterval: availableServicesModel.timeoutInterval
                                                                 }
                                                                 );
                        thisRequest.complete.connect(function(serviceData){

                            if (serviceData.keep === true) {
                                servicesListModel.get(serviceData.tileIndex).serviceInfo = JSON.parse(serviceData.serviceInfo);
                                if (!serviceData.useToken) {
                                    servicesListModel.get(serviceData.tileIndex).useTokenToAccess = false;
                                }
                            }
                            else {
                                servicesListModel.tilesToRemove.push(serviceData.tileIndex);
                            }

                            availableServicesModel.tileServiceSum -= serviceData.tileIndex;

                            if (tileServiceSum === 0) {
                                servicesListModel.removeBadTiles();
                            }

                            thisRequest.destroy(2000);
                        });

                        requests.push(thisRequest);
                    }

                    //----------------------------------------------------------

                    tileServiceSum = tileServiceSum + (tileServiceCount++);

                    servicesListModel.append(result);
                }
                catch(error) {
                    console.log(error);
                    appMetrics.reportError(error)
                }

            });

            if (response.nextStart > 0) {
                search(response.nextStart);
            }
            else {

                availableServicesModel.servicesCountReady(servicesListModel.count);

                if (servicesListModel.count > 0) {
                    for (var i = 0; i < servicesListModel.count; i++) {
                        requests[i].sendRequest();
                    }
                }
                else {
                    _getUserSavedTileServices();
                    //modelComplete();
                }

                busy = false;
            }
        }

        onFailed: {
            availableServicesModel.failed(error);
        }

        function start() {
            servicesListModel.clear();
            busy = true;
            search();
        }
    }

    // METHODS /////////////////////////////////////////////////////////////////

    function addService(url){

        // TODO: Combine this method with the tileServicesSearch onSuccess loop

        var newService = {
            "description" : "",
            "isArcgisTileService" : _isArcgisTileService(url),
            "isWebMercator" : true,
            "serviceUrl" : url,
            "url": url,
            "useTokenToAccess" : true,
            "serviceInfo" : {},
            "title": "User Added",
            "userAdded": true,
            "tpkId": "added_service_" + Date.now().toString()
        }

        var component = Qt.createComponent("AvailableServicesInfoRequest.qml");

        if (component.status === Component.Ready) {
            var thisRequest = component.createObject(parent,
                                                     {
                                                         portal:availableServicesModel.portal,
                                                         tileIndex: servicesListModel.count+1,
                                                         serviceUrl: url,
                                                         useTimeout: availableServicesModel.useTimeout,
                                                         timeoutInterval: availableServicesModel.timeoutInterval
                                                     }
                                                     );
            thisRequest.complete.connect(function(serviceData){

                if(serviceData.keep === true){
                    var inInfo = JSON.parse(serviceData.serviceInfo);
                    newService.serviceInfo = inInfo
                    newService.description = inInfo.description;
                    if(inInfo.hasOwnProperty("mapName")){
                        newService.title = inInfo.mapName;
                    }

                    if(!serviceData.useToken){
                        newService.useTokenToAccess = false;
                    }

                    servicesListModel.append(newService);
                    serviceAdded();

                    try {
                        var sql = "INSERT into 'other_tile_services' (special_id, url, service_info, user) ";
                        sql += "VALUES(:special_id, :url, :service_info, :user)"
                        var params = {
                            "special_id": newService.tpkId,
                            "url": newService.url,
                            "service_info": JSON.stringify(newService),
                            "user": portal.user.email
                        }

                        appDatabase.write(sql,params);
                    }
                    catch(e) {
                        console.log(e);
                    }
                }
                else{
                    serviceNotAdded();
                }

                thisRequest.destroy(2000);
            });

            thisRequest.sendRequest();
            //thisRequest.send();
        }
    }

    //--------------------------------------------------------------------------

    function _getUserSavedTileServices(){
        try {
            userAddedServices = appDatabase.read("SELECT * FROM 'other_tile_services' WHERE user IS '%1'".arg(portal.user.email));
            if (userAddedServices.count > 0){
                for (var x = 0; x < userAddedServices.count; x++){
                    servicesListModel.append(JSON.parse(userAddedServices.get(x).service_info));
                }
            }
        }
        catch(e){
            console.log(e);
        }
        finally {
            modelComplete();
        }
    }

    //--------------------------------------------------------------------------

    function _isArcgisTileService(url){
        if(url.indexOf("esri") > -1 || url.indexOf("arcgis") > -1 || url.indexOf("rest/services") > -1){
            return true;
        }
        else{
            return false;
        }
    }

    //--------------------------------------------------------------------------

    function _isWebMercator(sr){
        if ( sr === Singletons.Constants.kWebMercSR || sr === Singletons.Constants.kWebMercLatestWKID.toString() || sr === Singletons.Constants.kWebMercWKID.toString() ){
            return true;
        }
        else{
            return false;
        }
    }

    // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////////
    onModelComplete: {}

    // END /////////////////////////////////////////////////////////////////////
}
