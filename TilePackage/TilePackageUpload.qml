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

import QtQuick 2.0
import QtQuick.Dialogs 1.2
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
//------------------------------------------------------------------------------
import "../Portal"
//------------------------------------------------------------------------------

Item {

    id: tpkUpload

    // PROPERTIES //////////////////////////////////////////////////////////////

    property int kWebMercLatestWkid: 3857
    property int kWebMercWkid: 102100
    property string kWebMercator: "WGS_1984_Web_Mercator_Auxiliary_Sphere"

    property Portal portal
    property string tempFolderPath: AppFramework.temporaryFolder.path + "/tpktmp"
    property string mapServerJsonTempPath: tempFolderPath + "/mapserver.json"
    property string mapServerJsonZipPath: "servicedescriptions/mapserver/mapserver.json"
    property string tpkFilePath
    property string tpkServiceTitle: ""
    property string tpkServiceDesc: ""
    property bool isWebMercator: false
    property bool acceptAnySR: false
    property var tpkSpatialReference: { "wkid": null, "latestWkid": null }
    property FileFolder workFolder: FileFolder {}
    property double progress: 0.0

    property bool active
    property bool aborted

    signal srCheckComplete(var sr)
    signal uploadStarted()
    signal uploadStatus(string message)
    signal uploadProgress(string response)
    signal uploadFailed(var error)
    signal uploadCancelled(string response)
    signal uploadComplete(string id)
    signal uploadError(var error)

    // METHODS /////////////////////////////////////////////////////////////////

    function upload(tpkPath /*FileDialog fileUrl */, serviceTitle /* string optional */, serviceDescription /* string optional */){

        if(serviceTitle !== undefined && serviceTitle !== null && serviceTitle !== ""){
            tpkServiceTitle = serviceTitle;
        }

        if(serviceDescription !== undefined && serviceDescription !== null && serviceDescription !== ""){
            tpkServiceDesc = serviceDescription; // _cleanUpDescription(serviceDescription);
        }

        if(tpkSpatialReference.wkid === null){
            uploadStatus("TPKUpload: sr is null");
            getTPKSpatialReference(tpkPath);
        }

        if(isWebMercator){
            uploadStatus("TPKUpload: isWebMercator = true");
            _upload();
        }
        else{
            // Not Web Mercator
            uploadStatus("TPKUpload: not webmerc");
            acceptNonWebMercatorSR.open();
        }
    }

    //--------------------------------------------------------------------------

    function _upload(){

        if(isWebMercator || acceptAnySR){
            var formData = {
                "file": "@" + tpkFilePath,
                "type": "Tile Package",
                "title": tpkServiceTitle !== "" ? tpkServiceTitle : _createTPKTitle(),
                "description": tpkServiceDesc !== "" ? tpkServiceDesc : "Description not provided.",
                "spatialReference": (isWebMercator) ? kWebMercator : tpkSpatialReference.wkid,
                "token": portal.token,
                "f": "pjson"
            };

           //tpkUploadPortalItem.addItem(formData);
           tpkUploadRequest.send(formData);
           uploadStarted();
        }
        else{
            uploadError("Spatial Reference not set. Use upload method and not _upload.");
        }
    }

    //--------------------------------------------------------------------------

    function cancel(){
        //tpkUploadPortalItem.addItemNetworkRequest.abort();
        if(active){
            console.log("active and abort")
            aborted = true;
            //tpkUploadRequest.abort();
        }
        //uploadCancelled("Upload Cancelled by user");
    }

    //--------------------------------------------------------------------------

    function getTPKSpatialReference(tpkPath /*FileDialog fileUrl */) {

        tpkFilePath = AppFramework.resolvedPath(tpkPath);

        if (workFolder.removeFolder(tempFolderPath, true)) {

            workFolder.makePath(tempFolderPath);

            if (workFolder.makeFolder()) {

                tpkReader.path = tpkFilePath;

                var ok = tpkReader.extractFile(mapServerJsonZipPath, mapServerJsonTempPath);

                tpkReader.path = "";

                if(ok){
                    var mapJson = workFolder.readJsonFile(mapServerJsonTempPath);
                    if (mapJson.hasOwnProperty("contents")) {
                        if (mapJson.contents.hasOwnProperty("spatialReference")) {
                            var mapSR = mapJson.contents.spatialReference;
                            if (mapSR.hasOwnProperty("wkid")) {
                                tpkSpatialReference.wkid = mapSR.wkid;
                            }
                            if(mapSR.hasOwnProperty("latestWkid")){
                                tpkSpatialReference.latestWkid = mapSR.latestWkid;
                            }
                            isWebMercator = _tpkIsWebMercator();
                            srCheckComplete(tpkSpatialReference);
                        }
                    }
                }
                else{
                    uploadError("There was an error reading the spatial reference from the selected tpk file.");
                }
            } else {
                uploadError("Error creating a temporary work folder.");
            }
        }else{
            uploadError("Error deleting temporary folder. You may need to manually delete folder tpktmp from the application folder and try again.");
        }
    }

    //--------------------------------------------------------------------------

    function _tpkIsWebMercator(){

        var isWebMerc;

        if(tpkSpatialReference.latestWkid !== null && tpkSpatialReference.latestWkid === kWebMercLatestWkid){
            isWebMerc = true;
        }
        else if(tpkSpatialReference.latestWkid === null && tpkSpatialReference.wkid === kWebMercWkid){
            isWebMerc = true;
        }
        else{
            isWebMerc = false;
        }

        return isWebMerc;

    }

    //--------------------------------------------------------------------------

    function _createTPKTitle(){
        var extension = ".tpk";
        var fileName = tpkFilePath.substring( tpkFilePath.lastIndexOf('/') + 1 , tpkFilePath.indexOf(extension) );
        // fileName = ( fileName + "_" + Date.now().toString() );
        return fileName;
    }

    //--------------------------------------------------------------------------

    function _resetProperies(){
        acceptAnySR = false;
        isWebMercator = false;
        tpkSpatialReference.wkid = null;
        tpkSpatialReference.latestWkid = null;
        tpkServiceTitle = ""
        tpkServiceDesc = ""
        progress = 0.0;
    }

    //--------------------------------------------------------------------------

    function _cleanUpDescription(desc){
        return desc.substring(0, 32000);
    }

    // SIGNALS /////////////////////////////////////////////////////////////////

    onSrCheckComplete: {
        uploadStatus("SR Check Complete");
        workFolder.removeFolder(tempFolderPath, true);
    }

    onUploadStarted: {
        uploadStatus("Starting Upload of TPK");
        active = true;
    }

    onUploadProgress: {
    }

    onUploadFailed: {
        console.log("onUploadFailed:", error.message)
        uploadStatus("Upload Failed");
        workFolder.removeFolder(tempFolderPath, true);
        acceptAnySR = false;
        isWebMercator = false;
        active = false;
    }

    onUploadCancelled: {
        console.log(response);
        uploadStatus("Upload Cancelled");
        _resetProperies();
        active = false;
        aborted = false;
    }

    onUploadComplete: {
        console.log(id);
        uploadStatus("Upload Complete");
        active = false;
        _resetProperies();
    }

    onUploadError: {
        uploadStatus("Upload Error");
        workFolder.removeFolder(tempFolderPath, true);
        acceptAnySR = false;
        isWebMercator = false;
        active = false;
    }

    onProgressChanged: {
        // Abort once .04 is reached to avoid app crash
        if(tpkUpload.aborted && progress > 0.04){
            console.log("i can abort now");
            tpkUploadRequest.abort();
        }
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    NetworkRequest {

        id: tpkUploadRequest

        responseType: "json"
        method: "POST"
        url: tpkUpload.portal.restUrl + "/content/users/" + tpkUpload.portal.username + "/addItem"
        ignoreSslErrors: tpkUpload.portal && tpkUpload.portal.ignoreSslErrors

        headers {
            referrer: tpkUpload.portal.portalUrl
            userAgent: tpkUpload.portal.userAgent
        }

        onReadyStateChanged: {

            if (readyState === NetworkRequest.ReadyStateComplete) {

                if (status === 200) {
                    if(response){
                         if (response.error) {
                             console.log('200 and error')
                             tpkUpload.uploadFailed(response.error);
                        }
                        else {
                            tpkUpload.uploadComplete(response.id);
                        }
                    }
                    else{
                        console.log('no response');
                        tpkUpload.uploadComplete("-1");
                        //tpkUpload.uploadCancelled("Upload Cancelled");
                    }
                }
                else {
                    if(status === 0){
                        console.log("status is 0")
                        if(aborted){
                            tpkUpload.uploadCancelled("Upload Cancelled");
                        }
                    }

                    if(status !== 0){
                        tpkUpload.uploadFailed("Status is: %1".arg(status.toString()));
                    }
                }
            }
        }

        onProgressChanged: {
            tpkUpload.progress = progress;
        }
    }

    //--------------------------------------------------------------------------

    ZipReader {
        id: tpkReader

        onProgress: {}

        onError: {
            tpkUpload.uploadFailed("Error reading tpk.");
            tpkUpload.uploadError(result);
        }
    }

    //--------------------------------------------------------------------------

    MessageDialog {
        id: acceptNonWebMercatorSR
        title: "TPK's Spatial Reference is not Web Mercator"
        text: "This TPK's spatial reference is not Web Mercator and may not work as expected in your app. Click OK to continue upload or CANCEL to cancel upload."
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        modality: Qt.WindowModal
        onAccepted:{
            acceptAnySR = true;
            _upload();
            acceptNonWebMercatorSR.close();
        }
        onRejected:{
            uploadCancelled("Upload cancelled.");
            acceptNonWebMercatorSR.close();
        }
    }

    // END /////////////////////////////////////////////////////////////////////
}
