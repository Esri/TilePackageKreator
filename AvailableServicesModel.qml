import QtQuick 2.6
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
//--------------------------------------------------------------------------
import "Portal"
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
    property string searchQuery: '(type:"Map Service" AND owner:esri AND title:(for Export)) OR (type:"Map Service" AND owner:' + portal.username + ') OR (type:("Map Service") AND group:(access:org))'

    property ListModel servicesListModel: ListModel {
        property var tilesToRemove: []
        function removeBadTiles(){
            tilesToRemove.sort(function(a, b) {
                return b - a;
              });

            for(var i = 0; i < tilesToRemove.length; i++){
                servicesListModel.remove(tilesToRemove[i]);
            }

            availableServicesModel.modelComplete();
            tilesToRemove = [];
        }
    }

    signal servicesCountReady(int numberOfServices)
    signal modelComplete()
    signal failed(var error)

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

                try{
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
                        var thisRequest = component.createObject(parent, { portal:availableServicesModel.portal, tileIndex: tileServiceCount, serviceUrl: result.url } );
                        thisRequest.complete.connect(function(serviceData){

                            if(serviceData.keep === true){
                                servicesListModel.get(serviceData.tileIndex).serviceInfo = JSON.parse(serviceData.serviceInfo);
                                if(!serviceData.useToken){
                                    servicesListModel.get(serviceData.tileIndex).useTokenToAccess = false;
                                }
                            }
                            else{
                                servicesListModel.tilesToRemove.push(serviceData.tileIndex);
                            }

                            availableServicesModel.tileServiceSum -= serviceData.tileIndex;

                            if(tileServiceSum === 0){
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
                catch(error){
                    console.log(error);
                    appMetrics.reportError(error)
                }

            })

            if (response.nextStart > 0) {
                search(response.nextStart);
            }
            else {

                availableServicesModel.servicesCountReady(servicesListModel.count);

                for(var i = 0; i < servicesListModel.count; i++){
                    requests[i].send();
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
        if (sr === config.webMercSR || sr === config.webMercLatestWKID.toString() || sr === config.webMercWKID.toString()){
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
