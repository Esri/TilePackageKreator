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
import QtQuick.Dialogs 1.2
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
//------------------------------------------------------------------------------
import "../Portal"
//------------------------------------------------------------------------------

Item {

    id: tpkExport

    // PROPERTIES //////////////////////////////////////////////////////////////

    property Portal portal

    property bool active

    property bool estimateSizeSubmissionComplete: false
    property bool estimateSizeJobComplete: false
    property string estimateSizeJobId

    property bool exportTilesSubmissionComplete: false
    property bool exportTilesJobComplete: false
    property string exportTilesJobId

    property var currentItemServiceUrl: null
    property var currentItemGeometry: null
    property bool currentItemUsesToken
    property string currentItemGeometryType: ""
    property var currentItemLevels: null
    property string currentItemFilename: ""
    property string currentItemUuid: ""
    property var currentItemPortalOptions: null
    property var currentItemRequestInfo: null
    property int currentItemBufferDistance: 0

    property string tileCountErrorCode: "ERROR 001564"
    property string tileCountErrorMessage: qsTr("Requested tile count exceeds the maximum allowed number of tiles to be exported.")

    property FileFolder appFolder: FileFolder { path: AppFramework.userHomePath + "/ArcGIS" }
    property string defaultTpkFolder: appFolder.path + "/My Tile Packages"
    property var userDefinedTpkFolder: null

    property string estimateTilesUrl: "estimateExportTilesSize"
    property string exportTilesUrl: "exportTiles"

    signal exportComplete(string itemUrl)
    signal exportStarted()
    signal exportCancelled(string response)
    signal exportGeometryTransformStarted()
    signal exportGeometryTransformComplete(var geometries)
    signal exportDownloadStarted()
    signal exportDownloadComplete(var file)
    signal exportEstimateSizeStarted()
    signal exportEstimateSizeComplete(var response)
    signal exportError(string message)
    signal exportProgress(string message)

    // METHODS /////////////////////////////////////////////////////////////////

    function exportTiles(tileService /* Required {"url": string, "usesToken": boolean} */, levels /* Required */, geometry /* Required {"geometryType": string, "geometries": object} */, bufferDistance /* int optional */ ,filename /* string optional */, saveToFolder /* string optional */, portalOptions /* object optional { "uploadToPortal": bool, "serviceTitle": string, "serviceDescription": string } */) {

        tpkExport.active = true;

        // has geometry? -------------------------------------------------------

        if(geometry !== undefined && geometry !== null && geometry !== "" && geometry.hasOwnProperty("geometryType") && geometry.hasOwnProperty("geometries")){

            // has tileService object? -----------------------------------------

            if(tileService !== undefined && tileService !== null){
                currentItemServiceUrl = (tileService.hasOwnProperty("url")) ? tileService.url : null;
                currentItemUsesToken = (tileService.hasOwnProperty("usesToken")) ? tileService.usesToken : true;
            }

            // has levels? -----------------------------------------------------

            currentItemLevels = (levels !== undefined && levels !== null && levels !== "") ? levels : null;

            // has bufferDistance? ----------------------------------------------

            currentItemBufferDistance = (bufferDistance !== undefined && bufferDistance !== null && bufferDistance !== "") ? bufferDistance : 0;

            // has filename? ---------------------------------------------------

            currentItemFilename = (filename !== undefined && filename !== null && filename !== "") ? filename : "";

            // has saveToFolder? -----------------------------------------------

            userDefinedTpkFolder = (saveToFolder !== undefined && saveToFolder !== null && saveToFolder !== "") ? saveToFolder : null;

            // has portalOptions? ----------------------------------------------

            if(portalOptions !== undefined && portalOptions !== null){
                console.log(portalOptions);
                if(portalOptions.hasOwnProperty("uploadToPortal") && portalOptions.hasOwnProperty("serviceTitle")){
                    currentItemPortalOptions = portalOptions;
                }
                if(!portalOptions.hasOwnProperty("serviceTitle") || portalOptions.serviceTitle === "" || portalOptions.serviceTitle === null){
                    exportError(qsTr("A Service Title is required to upload online. You will need to manually upload after export and download complete."));
                }
            }
            else{
                currentItemPortalOptions = null;
            }

            // Route export according to geometry type now ---------------------

            currentItemGeometryType = geometry.geometryType;

            if(currentItemGeometryType === "esriGeometryEnvelope" || currentItemGeometryType === "esriGeometryPolygon"){
                estimateSize(currentItemServiceUrl, currentItemLevels, geometry)
            }

            if(currentItemGeometryType === "esriGeometryPolyline"){
                exportGeometryTransformStarted();
                tpkGeoHelper.buffer(geometry, geometry.geometries[0].spatialReference.wkid, currentItemBufferDistance);
            }
        }
        else{
            exportError(qsTr("Export geometry is missing. Export cannot be completed"));
            exportCancelled(qsTr("Export cancelled due to missing geometry input."));
        }

    }

    //--------------------------------------------------------------------------

    function _export(){
        tpkExportPortalRequest.url = currentItemServiceUrl + "/" + exportTilesUrl;

        console.log("-------------------------- url: ", tpkExportPortalRequest.url);

        var requestInfo = _createRequestInfo(currentItemLevels, currentItemGeometry);

        if(currentItemRequestInfo !== null){
            tpkExportPortalRequest.sendRequest(currentItemRequestInfo);
            exportProgress(qsTr("Submitting Export Tiles Request."));
            exportStarted();
        }
        else{
            exportError(qsTr("Error submitting export tiles request"));
        }
    }

    //--------------------------------------------------------------------------

    function estimateSize(serviceUrl, levels, geometry) {

        _clearTimers();

        _resetProperties();

        currentItemGeometry = geometry;
        currentItemLevels = levels;
        currentItemServiceUrl = serviceUrl;

        tpkExportPortalRequest.url = serviceUrl + "/" + estimateTilesUrl;

        currentItemRequestInfo = _createRequestInfo(levels, geometry);

        tpkExportPortalRequest.sendRequest(currentItemRequestInfo);

    }

    //--------------------------------------------------------------------------

    function download(itemUrl){

        currentItemUuid = AppFramework.createUuidString(2);
        var thisFilename = (currentItemFilename !== "") ? currentItemFilename + "_" + currentItemUuid : "tpk_export" + currentItemUuid;
        tpkNetworkRequest.fileName = thisFilename;
        tpkNetworkRequest.url = itemUrl;

        if(userDefinedTpkFolder === null){
            if(appFolder.makePath(defaultTpkFolder)){
                tpkNetworkRequest.responsePath = defaultTpkFolder + "/" + thisFilename + ".tpk";
            }else{
                exportError(qsTr("Error creating download folder for tpk."));
            }
        }
        else{
            tpkNetworkRequest.responsePath = userDefinedTpkFolder + "/" + thisFilename + ".tpk";
        }

        tpkNetworkRequest.send();
        tpkNetworkRequest.aborted = false;
        tpkNetworkRequest.active = true;
        exportDownloadStarted();
    }

    //--------------------------------------------------------------------------

    function _createRequestInfo(levels, geometry) {

        // http://tiledbasemaps.arcgis.com/arcgis/sdk/rest/index.html#/Export_Tiles/02ss000000p8000000/

        var requestInfo = {};

        requestInfo["f"] = "json";
        requestInfo["useToken"] = currentItemUsesToken;

        // tilepackage:
        // Description: Allows exporting either a tile package or a cache raster data set.
        // If the value is true output will be in tile package format and if the value is false
        // Cache Raster data set is returned. The default value is false
        requestInfo["tilePackage"] = true;

        // exportBy: LevelID | Resolution | Scale
        // The extent (bounding box) of the tile package or the cache dataset to be exported.
        // If extent does not include a spatial reference, the extent values are assumed to be
        // in the spatial reference of the map. The default value is full extent of the tiled map service.
        requestInfo["exportBy"] = "LevelID";

        // levels:
        // Specify the tiled service levels to export.
        // The values should correspond to Level IDs, cache scales or the Resolution as specified in exportBy parameter.
        // The values can be comma separated values or a range.
        requestInfo["levels"] = levels;

        // optimizeTilesForSize:  true || false
        // (Optional) Use this parameter to enable compression of JPEG tiles and reduce the size of
        // the downloaded tile package or the cache raster data set.
        // Compressing tiles slightly compromises on the quality of tiles but helps reduce the size of the download.
        // Try out sample compressions to determine the optimal compression before using this feature.
        /* requestInfo["optimizeTilesForSize"] = true; */

        // compressionQuality: 0 to 100
        // When optimizeTilesForSize=true you can specify a compression factor.
        // The value must be between 0 and 100.
        /* requestInfo["compressionQuality"] = 90 */

        switch(currentItemGeometryType){
            case "esriGeometryEnvelope":
                requestInfo["exportExtent"] = JSON.stringify(geometry.geometries);
                break;
            case "esriGeometryPolyline":
            case "esriGeometryPolygon":
                requestInfo["exportExtent"] = "DEFAULT";
                var aoi = {
                    "geometryType": "esriGeometryPolygon",
                    "features" : [{"geometry": geometry.geometries[0]}]
                };
                requestInfo["areaOfInterest"] = JSON.stringify(aoi);
                break;
            default:
                break;
        }

        console.log("Request: ",JSON.stringify(requestInfo));

        return requestInfo;
    }

    //--------------------------------------------------------------------------

    function _clearTimers(){
        if (checkEstimateSizeRequestTimer.running === true) {
            checkEstimateSizeRequestTimer.stop();
        }
        if (checkExportTilesRequestTimer.running === true) {
            checkExportTilesRequestTimer.stop();
        }
    }

    //--------------------------------------------------------------------------

    function _resetProperties(){
        currentItemGeometry = null;
        currentItemLevels = null;
        currentItemServiceUrl = null;
        currentItemBufferDistance = 0;
        //currentItemGeometryType = "";
    }

    //--------------------------------------------------------------------------

    function deleteLocalTilePackage(filename){
        try{
            // TODO. Fix on Windows as deleting the file is not allowed cause app has a lock on it.
            appFolder.removeFile(filename);
        }
        catch(e){
            console.log(e);
        }
    }

    //--------------------------------------------------------------------------

    function cancel(){

        if(tpkExportPortalRequest.active){
            tpkExportPortalRequest.abort();
        }

        if(checkJobStatusPortalRequest.active){
            checkJobStatusPortalRequest.abort();
        }

        if(getMapTileUrl.active){
            getMapTileUrl.abort();
        }

        if(getEstimateSize.active){
            getEstimateSize.abort();
        }

        if(tpkNetworkRequest.active){
            tpkNetworkRequest.aborted = true;
            tpkNetworkRequest.abort();
        }

        if(tpkGeoHelper.active){
            tpkGeoHelper.cancel();
        }

        _clearTimers();

        _resetProperties();

        exportError(qsTr("Export Cancelled."));

    }

    // SIGNALS /////////////////////////////////////////////////////////////////

    onExportCancelled: {
        tpkExport.active = false;
    }

    onExportDownloadComplete: {
        tpkExport.active = false;
    }

    onExportError: {
        tpkExport.active = false;
    }

    onExportGeometryTransformComplete: {
        estimateSize(currentItemServiceUrl, currentItemLevels, geometries);
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    PortalRequest{
        id: tpkExportPortalRequest
        portal: tpkExport.portal

        onSuccess: {

            // switch on portal request url to reuse this object
            try{
                var callingUrl = tpkExportPortalRequest.url.toString();
                callingUrl = callingUrl.substring(callingUrl.lastIndexOf("/")+1, callingUrl.length);
                var response = JSON.parse(responseText);

                if(callingUrl === estimateTilesUrl){
                    if(response.hasOwnProperty("jobId")){
                        exportEstimateSizeStarted();
                        console.log("Estimate Job Submitted Successfully.");
                        estimateSizeSubmissionComplete = true;
                        estimateSizeJobId = response.jobId;
                        tpkExport.exportProgress(qsTr("Estimate Job Submitted Successfully."));
                        checkJobStatusPortalRequest.url = tpkExportPortalRequest.url + "/jobs/" + estimateSizeJobId + "?f=pjson";
                        checkEstimateSizeRequestTimer.start();
                    }
                    else{
                        console.log("Cannot estimate size");
                        continueExportWithoutSizeEstimate.open();
                    }
                }

                if(callingUrl === exportTilesUrl){
                    if(response.hasOwnProperty("jobId")){
                        tpkExport.exportProgress(qsTr("Export Request Successfully Submitted. App will check on export status every 10 seconds. Please wait."));
                        exportTilesSubmissionComplete = true;
                        exportTilesJobId = response.jobId;
                        checkJobStatusPortalRequest.url = tpkExportPortalRequest.url + "/jobs/" + exportTilesJobId + "?f=pjson";
                        checkExportTilesRequestTimer.start();
                    }
                    else{
                        tpkExport.exportError(qsTr("ERROR: Export request was not submitted. This tile service may not support exporting tiles."));
                    }
                }
            }
            catch(error){
                tpkExport.exportError(qsTr("%1 %2".arg("Error:").arg(error)));
            }
        }

        onError: {
            tpkExport.exportError(error.message);
        }

        onFailed: {
            tpkExport.exportError(error.message);
        }
    }

    //--------------------------------------------------------------------------

    PortalRequest{
        id: checkJobStatusPortalRequest
        portal: tpkExport.portal

        onSuccess: {
            var response = JSON.parse(responseText);

            if (response.jobStatus === "esriJobSucceeded") {

                // User map tile service exports return an output parameter
                // It is unclear what a user estimate tile size would return
                // TODO: Add check for user estimate tile size and respond accordingly

                if(response.hasOwnProperty("output")){
                    if(response.output.hasOwnProperty("outputUrl")){
                        if (checkExportTilesRequestTimer.running === true) {
                            checkExportTilesRequestTimer.stop();
                            tpkExport.exportProgress("Export Complete");
                            tpkExport.exportComplete(response.output.outputUrl);

                            var tpkUrl = response.output.outputUrl.toString();

                            // Required for now per issue: /appstudio-framework/issues/48
                            var headerJson = tpkNetworkRequest.headers.json;
                            headerJson["Content-Type"] = "";
                            tpkNetworkRequest.headers.json = headerJson;

                            tpkExport.download(tpkUrl);
                        }
                    }
                }

                // Esri map tile service exports return a results parameter

                if(response.hasOwnProperty("results")){
                    if (response.results.hasOwnProperty("out_service_url")) {
                        if (response.results.out_service_url.hasOwnProperty("paramUrl")) {

                            if (checkEstimateSizeRequestTimer.running === true) {
                                checkEstimateSizeRequestTimer.stop();
                                getEstimateSize.url = tpkExportPortalRequest.url + "/jobs/"
                                        + estimateSizeJobId + "/results/out_service_url?f=pjson";
                                getEstimateSize.sendRequest({ "useToken": currentItemUsesToken });
                            }

                            if (checkExportTilesRequestTimer.running === true) {
                                checkExportTilesRequestTimer.stop();
                                getMapTileUrl.url = tpkExportPortalRequest.url + "/jobs/"
                                        + exportTilesJobId + "/results/out_service_url?f=pjson";
                                getMapTileUrl.sendRequest({ "useToken": currentItemUsesToken });
                            }


                        }
                    }
                }
            }
            else {
                if (response.jobStatus === "esriJobFailed") {
                    _clearTimers();
                    var errorMessage = "";
                    if(response.messages.length > 0){
                        for(var i = 0; i < response.messages.length; i++){
                            if(response.messages[i].description.indexOf(tileCountErrorCode) > -1 ){
                                errorMessage = tileCountErrorCode + ": " + tileCountErrorMessage;
                                break;
                            }
                        }
                    }else{
                        errorMessage = response.description;
                    }

                    tpkExport.exportProgress(qsTr("Export Failed"));
                    tpkExport.exportError(errorMessage);
                }

                if(response.jobStatus === "esriJobCancelled"){
                    _clearTimers();
                    tpkExport.exportCancelled(JSON.stringify(response.messages));
                }
            }
        }
        onError: {}
        onProgressChanged: {}
        onFailed: {
            _clearTimers();
            var errorMessage = "Export Failed";
            try{
                if(response.messages.length > 0){
                    for(var i = 0; i < response.messages.length; i++){
                        if(response.messages[i].description.indexOf("ERROR") > -1 ){
                            errorMessage = response.messages[i].description;
                            break;
                        }
                    }
                }
            }
            catch(e){
            }
            tpkExport.exportProgress(qsTr("Export Failed"));
            tpkExport.exportError(errorMessage);
        }
    }

    //--------------------------------------------------------------------------

    PortalRequest {
        id: getEstimateSize
        portal: tpkExport.portal
        onSuccess: {
            var response = JSON.parse(responseText);
            var package_size = (parseFloat(response.value.totalSize,10) / 1048576).toFixed(2);
            var number_of_tiles = response.value.totalTilesToExport;
            tpkExport.exportProgress(qsTr( "%1 %2 %3 %4".arg("Estimate Size Complete: File Size:").arg(package_size).arg("MB, Number of Tiles:").arg(number_of_tiles) )); // + package_size + " MB, Number of Tiles: " + number_of_tiles);
            exportEstimateSizeComplete({"sizeInMegabytes": package_size, "numberOfTiles": number_of_tiles});
            _export();
        }
        onFailed: {
            tpkExport.exportError(responseText);
        }
    }

    //--------------------------------------------------------------------------

    PortalRequest {
        id: getMapTileUrl
        portal: tpkExport.portal
        onSuccess: {
            var response = JSON.parse(responseText);
            getMapTileTpkUrl.url = response.value + "/?f=pjson"
            getMapTileTpkUrl.sendRequest({ "useToken": currentItemUsesToken });
        }
        onFailed: {
            //tpkExport.exportError("<p>Failed to get Map Tile URL for download: " + responseText + "</p>");
            tpkExport.exportError(qsTr("%1 %2").arg("Failed to get Map Tile URL for download:").arg(responseText));
        }
    }

    //--------------------------------------------------------------------------

    PortalRequest {
        id: getMapTileTpkUrl
        portal: tpkExport.portal

        onSuccess: {
            try{
                var response = JSON.parse(responseText);
                if(response.hasOwnProperty("files")){
                    if(response.files[0].hasOwnProperty("url")){
                        var tpkPath = response.files[0].url;
                        tpkExport.exportComplete(tpkPath.toString());
                        tpkExport.download(tpkPath);
                    }
                }
                else{
                    tpkExport.exportError(qsTr("Failed to retrieve download file url."));
                }
            }
            catch(e){
                 tpkExport.exportError(qsTr("Error retrieving download file url."));
            }
        }

        onFailed: {
            tpkExport.exportError(qsTr("%1 %2").arg("Failed to get Map Tile TPK url for download:").arg(responseText));
        }

    }

    //--------------------------------------------------------------------------

    NetworkRequest{
        id: tpkNetworkRequest

        property string fileName

        property bool active
        property bool aborted

        responseType: "zip"

        method: "GET"

        headers.userAgent: portal.userAgent

        onReadyStateChanged: {

            if (readyState === NetworkRequest.ReadyStateComplete){

                if (status === 200) {
                    if(!aborted){
                        console.log(tpkNetworkRequest.responsePath.toString());
                        tpkExport.exportDownloadComplete({
                                                             "name": tpkNetworkRequest.fileName,
                                                             "path": tpkNetworkRequest.responsePath
                                                         });
                        tpkNetworkRequest.active = false;
                    }
                }
                else {
                    tpkExport.exportError(qsTr("There was an error downloading the file."));
                }
            }
            else{
                tpkExport.exportProgress(qsTr("downloading"));
            }
        }
    }

    //--------------------------------------------------------------------------

    TilePackageGeometryHelper{
        id: tpkGeoHelper

        onComplete: {
            console.log(JSON.stringify(geometries));
            console.log('now estimate based on this geometry');
            tpkExport.exportGeometryTransformComplete(geometries);
        }

        onError: {
        }

        onSuccess: {
        }

    }

    //--------------------------------------------------------------------------

    MessageDialog {
        id: continueExportWithoutSizeEstimate
        title: qsTr("Estimate Tile Size Not Available")
        text: qsTr("Estimating tile size is not be available for this service. You can continue to submit an export request, but this request may fail if the request exceeds allowed tile count and size amount. Press OK to proceed to continue export.")
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        modality: Qt.WindowModal
        onAccepted:{
            _export();
            continueExportWithoutSizeEstimate.close();
        }
        onRejected:{
            _resetProperties();
            exportCancelled(qsTr("Export cancelled."));
            continueExportWithoutSizeEstimate.close();
        }
    }

    //--------------------------------------------------------------------------

    Timer {
        id: checkEstimateSizeRequestTimer
        interval: 4000 /*15000*/
        running: false
        repeat: true
        onTriggered: checkJobStatusPortalRequest.sendRequest({ "useToken": currentItemUsesToken })
    }

    //--------------------------------------------------------------------------

    Timer {
        id: checkExportTilesRequestTimer
        interval: 10000 /*30000*/
        running: false
        repeat: true
        onTriggered: checkJobStatusPortalRequest.sendRequest({ "useToken": currentItemUsesToken })
    }

    // END /////////////////////////////////////////////////////////////////////
}
