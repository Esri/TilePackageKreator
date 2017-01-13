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

import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtLocation 5.3
import QtPositioning 5.3
import QtGraphicalEffects 1.0
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
//------------------------------------------------------------------------------
import "Portal"
import "TilePackage"
import "ProgressIndicator"
import "DeepLinkingRequest"
import "HistoryManager"
import "Geometry"
import "MapViewPlus" as MapView
//------------------------------------------------------------------------------

Item {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: exportView

    property Portal portal
    property Config config
    property bool exporting: false
    property bool uploading: false
    property var currentTileService: null

    signal exportStarted()
    signal exportComplete()

    // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////////

    Component.onCompleted: {
        console.log(currentTileService);
        var serviceInfo = currentTileService["serviceInfo"];
        if(serviceInfo !== null){
            if(serviceInfo.hasOwnProperty("tileInfo")){
                if(serviceInfo.tileInfo.hasOwnProperty("lods")){
                    var availableLevels = (parseInt(serviceInfo.tileInfo.lods.length,10) - 1);
                    exportDetails.maxLevels = availableLevels > 19 ? 19 : availableLevels;
                    mapViewPlus.map.maximumZoomLevel = exportDetails.maxLevels;
                }
            }
        }

        if(calledFromAnotherApp && dlr.saveToPath !== null){
            exportDetails.exportToFolder = AppFramework.resolvedPathUrl(dlr.saveToPath);
            exportDetails.defaultSaveToLocation = dlr.saveToPath;
        }
        else{
            exportDetails.defaultSaveToLocation = tpkExport.defaultTpkFolder;
            exportDetails.exportToFolder = AppFramework.resolvedPathUrl(tpkExport.defaultTpkFolder);
        }
    }

    //--------------------------------------------------------------------------

    Stack.onStatusChanged: {
        if(Stack.status === Stack.Deactivating){
            mainView.appToolBar.toolBarTitleLabel = "";
        }
        if(Stack.status === Stack.Activating){
            mainView.appToolBar.backButtonEnabled = true;
            mainView.appToolBar.backButtonVisible = true;
            mainView.appToolBar.historyButtonEnabled = true;
            mainView.appToolBar.toolBarTitleLabel = qsTr("Create New Tile Package")
        }
    }

    //--------------------------------------------------------------------------

    onExportingChanged: {
        mainView.appToolBar.enabled = exporting ? false : true
    }

    //--------------------------------------------------------------------------

    onExportStarted: {
        exporting = true;
        exportStatusIndicator.hide();
        tpkExportStatusOverlay.visible = true;
        tpkExportStatusOverlay.opacity = 1;
    }

    //--------------------------------------------------------------------------

    onExportComplete: {
        exporting = false;
        fader.start();
        exportDetails.reset();
        tilePackageSizeEstimate.text = "Tiles: -- Size: --";
    }

    // UI //////////////////////////////////////////////////////////////////////

    Rectangle {
        anchors.fill: parent
        color: "#eee"

        ColumnLayout {
            id: exportTpkViewColumnLayout
            anchors.fill: parent
            spacing: 1 * AppFramework.displayScaleFactor

        // MAP AND DETAILS SECTION /////////////////////////////////////////////

        Rectangle {
            id: mapAndDetailsSection
            Layout.fillWidth: true
            Layout.fillHeight: true
            enabled: (exporting) ? false : true
            clip: true
            color: config.subtleBackground

            RowLayout {
                anchors.fill: parent
                spacing: 1

                // MAP SECTION /////////////////////////////////////////////////

                Rectangle {
                    color: "#fff"
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout{
                        anchors.fill: parent
                        spacing:0

                        // MAP CONTAINER ///////////////////////////////////////

                        MapView.MapViewPlus{
                            id: mapViewPlus
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            clip: true

                            mapViewPlusPortal: exportView.portal
                            mapDefaultLat: app.info.properties.mapDefaultLat
                            mapDefaultLong: app.info.properties.mapDefaultLong
                            mapDefaultZoomLevel: (calledFromAnotherApp && dlr.zoomLevel !== null) ? dlr.zoomLevel : app.info.properties.mapDefaultZoomLevel
                            mapDefaultCenter: (calledFromAnotherApp && dlr.center !== null) ? dlr.center : {"lat": app.info.properties.mapDefaultLat, "long": app.info.properties.mapDefaultLong }
                            mapTileService: currentTileService.url
                            mapTileServiceUsesToken: currentTileService.useTokenToAccess

                            Component.onCompleted: {
                                zoomLevelIndicator.text = "%1".arg(parseFloat(mapViewPlus.map.zoomLevel).toFixed(1));
                            }

                            onZoomLevelChanged: {
                                zoomLevelIndicator.text = "%1".arg(parseFloat(level).toFixed(1));
                            }

                            onPositionChanged: {
                               if(!cursorIsOffMap){
                                    _displayCoordinates(position.asCoords);
                                }
                                else{
                                    currentCursorLatLong.text = "-- --";
                                }
                            }

                            onDrawingCleared: {
                                tilePackageSizeEstimate.text = "Tiles: -- Size: --";
                            }

                            onDrawingStarted: {
                            }

                            onDrawingFinished: {
                                if(mapViewPlus.topLeft !== null && mapViewPlus.bottomRight !== null && mapViewPlus.geometryType !== "multipath"){
                                    var tlAsXY = coordConverter.lngLatToXY(mapViewPlus.topLeft);
                                    var brAsXY = coordConverter.lngLatToXY(mapViewPlus.bottomRight);
                                    tpkEstimateSize.calculate(tlAsXY, brAsXY, exportDetails.tpkZoomLevels);
                                }
                            }
                        }

                        // MAP TOOL BAR ////////////////////////////////////////

                        Rectangle{
                            id: mapInfoToolbar
                            Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                            Layout.fillWidth: true
                            color:config.subtleBackground

                            RowLayout{
                                anchors.fill: parent
                                spacing: 1

                                //----------------------------------------------

                                Rectangle{
                                    id: zoomLevelIndicatorContainer
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 140 * AppFramework.displayScaleFactor

                                    ColumnLayout{
                                        spacing:0
                                        anchors.fill: parent

                                        Rectangle{
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height / 2
                                            color: app.info.properties.toolBarBackgroundColor

                                            Text{
                                                anchors.fill: parent
                                                text: qsTr("Zoom Level")
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                color: "#fff"
                                                font.pointSize: config.smallFontSizePoint
                                                font.family: notoRegular.name

                                                Accessible.role: Accessible.Heading
                                                Accessible.name: text
                                            }
                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            Text{
                                                id: zoomLevelIndicator
                                                anchors.fill: parent
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                text: "--"
                                                font.family: notoRegular.name

                                                Accessible.role: Accessible.Indicator
                                                Accessible.name: text
                                                Accessible.description: qsTr("This text indicated the current zoom level of the map.")
                                            }
                                        }
                                    }
                                }

                                //----------------------------------------------

                                Rectangle{
                                    id: currentCursorLatLongContainer
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    ColumnLayout{
                                        spacing:0
                                        anchors.fill: parent

                                        Rectangle{
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height / 2
                                            color: app.info.properties.toolBarBackgroundColor

                                            Text{
                                                anchors.fill: parent
                                                text: qsTr("Cursor Coordinate")
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                color: "#fff"
                                                font.pointSize: config.smallFontSizePoint
                                                font.family: notoRegular.name

                                                Accessible.role: Accessible.Heading
                                                Accessible.name: text
                                            }
                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            Text{
                                                id:currentCursorLatLong
                                                anchors.fill: parent
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                text: "-- --"
                                                font.family: notoRegular.name

                                                Accessible.role: Accessible.Indicator
                                                Accessible.name: text
                                                Accessible.description: qsTr("This text denotes the current latitude and longitude position of the mouse cursor on the map.")
                                            }
                                        }
                                    }
                                }

                                //----------------------------------------------

                                Rectangle{
                                    id: tilePackageSizeEstimateContainer
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    ColumnLayout{
                                        spacing:0
                                        anchors.fill: parent

                                        Rectangle{
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height / 2
                                            color: app.info.properties.toolBarBackgroundColor

                                            Text{
                                                anchors.fill: parent
                                                text: qsTr("Estimated Output Size")
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                color: "#fff"
                                                font.pointSize: config.smallFontSizePoint
                                                font.family: notoRegular.name

                                                Accessible.role: Accessible.Heading
                                                Accessible.name: text
                                            }
                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            Text{
                                                anchors.fill: parent
                                                visible: mapViewPlus.geometryType === "multipath"
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                text: "Not Available with Paths"
                                                font.family: notoRegular.name

                                                Accessible.ignored: mapViewPlus.geometryType !== "multipath"
                                                Accessible.role: Accessible.Indicator
                                                Accessible.name: text
                                                Accessible.description: qsTr("This text denotes the estimated output size for the current geometry and zoom levels. Not currently available with paths.")

                                            }

                                            Text{
                                                id:tilePackageSizeEstimate
                                                visible: mapViewPlus.geometryType !== "multipath"
                                                anchors.fill: parent
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                text: "Tiles: -- Size: --"
                                                font.family: notoRegular.name

                                                Accessible.ignored: mapViewPlus.geometryType === "multipath"
                                                Accessible.role: Accessible.Indicator
                                                Accessible.name: text
                                                Accessible.description: qsTr("This text denotes the estimated output size for the current geometry and zoom levels.")
                                            }
                                        }
                                    }
                                }
                                //----------------------------------------------
                            }
                        }
                    }
                }

                // TPK EXPORT DETAILS //////////////////////////////////////////

                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 300 * AppFramework.displayScaleFactor
                    color: "#fff"
                    Accessible.role: Accessible.Pane

                   DetailsForm{
                        id: exportDetails
                        height: parent.height
                        width: parent.width
                        anchors.fill: parent
                        enabled: true
                        config: exportView.config

                        exportAndUpload: true
                        exportPathBuffering: mapViewPlus.geometryType === "multipath"
                        currentTileService: exportView.currentTileService
                        tpkTitle: exportView.extractDefaultTPKTitle(exportView.currentTileService.title)

                        onExportZoomLevelsChanged: {
                            if(mapViewPlus.topLeft !== null && mapViewPlus.bottomRight !== null){
                                var tlAsXY = coordConverter.lngLatToXY(mapViewPlus.topLeft);
                                var brAsXY = coordConverter.lngLatToXY(mapViewPlus.bottomRight);
                                tpkEstimateSize.calculate(tlAsXY, brAsXY, exportDetails.tpkZoomLevels);
                            }
                        }
                    }
                }
            }

            // EXPORT OVERLAY //////////////////////////////////////////////////

            Rectangle{
                id: tpkExportStatusOverlay
                color:"transparent"
                anchors.fill: parent
                visible: false

                Rectangle{
                    anchors.fill:parent
                    opacity: .9
                    color:config.subtleBackground
                    z:100
                }

                ColumnLayout{
                    id:exportStatus
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 10 * AppFramework.displayScaleFactor
                    z:101

                    ProgressIndicator{
                        id:estimateSizeProgressIndicator
                        statusTextFontSize:config.smallFontSizePoint
                        statusTextMinimumFontSize:6 * AppFramework.displayScaleFactor
                        statusTextLeftMargin:10 * AppFramework.displayScaleFactor
                        iconContainerLeftMargin: 5 * AppFramework.displayScaleFactor
                        iconContainerHeight: this.containerHeight - 5
                        Layout.fillWidth: true
                        visible: false
                    }
                    ProgressIndicator{
                        id:exportCompleteProgressIndicator
                        statusTextFontSize:config.smallFontSizePoint
                        statusTextMinimumFontSize:6 * AppFramework.displayScaleFactor
                        statusTextLeftMargin:10 * AppFramework.displayScaleFactor
                        iconContainerLeftMargin: 5 * AppFramework.displayScaleFactor
                        iconContainerHeight: this.containerHeight - 5
                        Layout.fillWidth: true
                        visible: false
                    }

                    ProgressIndicator{
                        id: downloadProgressIndicator
                        statusTextFontSize:config.smallFontSizePoint
                        statusTextMinimumFontSize:6 * AppFramework.displayScaleFactor
                        statusTextLeftMargin:10 * AppFramework.displayScaleFactor
                        iconContainerLeftMargin: 5 * AppFramework.displayScaleFactor
                        iconContainerHeight: this.containerHeight - 5
                        Layout.fillWidth: true
                        visible: false
                    }

                    ProgressIndicator{
                        id: uploadProgressIndicator
                        statusTextFontSize:config.smallFontSizePoint
                        statusTextMinimumFontSize:6 * AppFramework.displayScaleFactor
                        statusTextLeftMargin:10 * AppFramework.displayScaleFactor
                        iconContainerLeftMargin: 5 * AppFramework.displayScaleFactor
                        iconContainerHeight: this.containerHeight - 5
                        Layout.fillWidth: true
                        visible: false
                    }

                    ProgressIndicator{
                        id: exportErrorProgressIndicator
                        statusTextFontSize:config.smallFontSizePoint
                        statusTextMinimumFontSize:6
                        statusTextLeftMargin:10 * AppFramework.displayScaleFactor
                        iconContainerLeftMargin: 5 * AppFramework.displayScaleFactor
                        iconContainerHeight: this.containerHeight - 5
                        Layout.fillWidth: true
                        visible: false
                    }
                }
            }
        }

        // BOTTOM TASK BAR /////////////////////////////////////////////////////

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60 * AppFramework.displayScaleFactor
            color: "#fff"

            RowLayout {
                anchors.fill: parent
                spacing: 0

                //--------------------------------------------------------------

                Rectangle {
                    color: "#fff"
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    Rectangle{
                        id: exportStatusContainer
                        anchors.fill: parent
                        anchors.margins: 10 * AppFramework.displayScaleFactor

                        StatusIndicator{
                            id: exportStatusIndicator
                            anchors.fill: parent
                            containerHeight: parent.height
                            hideAutomatically: true
                            statusTextFontSize: config.baseFontSizePoint
                            showDismissButton: true

                            onLinkClicked: {
                               if(calledFromAnotherApp){
                                   // TODO: Decide if the app should purge deep link request on link back to calling application
                                   // dlr.reset();
                                   // calledFromAnotherApp = false;
                               }
                           }
                        }
                    }
                }

                //--------------------------------------------------------------

                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 190 * AppFramework.displayScaleFactor
                    color: "#fff"
                    visible: !exporting

                    Button {
                        id: exportTPKBtn
                        anchors.fill: parent
                        anchors.margins: 10 * AppFramework.displayScaleFactor
                        enabled: (exportDetails.tpkTitle !== "" /*tpkTitleTextField.text !== ""*/ && mapViewPlus.userDrawnExtent) ? true : false
                        style: ButtonStyle {
                            background: Rectangle {
                                anchors.fill: parent
                                color: config.buttonStates(control)
                                radius: app.info.properties.mainButtonRadius
                                border.width: (control.enabled) ? app.info.properties.mainButtonBorderWidth : 0
                                border.color: app.info.properties.mainButtonBorderColor
                            }
                        }

                        RowLayout{
                            spacing:0
                            anchors.fill: parent

                            Text {
                                id: exportTPKBtnText
                                color: app.info.properties.mainButtonFontColor
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                textFormat: Text.RichText
                                text: (!exporting) ? qsTr("Create Tile Package") : "Creating"
                                font.pointSize: config.baseFontSizePoint
                                font.family: notoRegular.name
                            }

                            ProgressIndicator{
                                id: btnStatusIndicator
                                visible: (!exporting) ? false : true
                                Layout.preferredWidth: parent.height
                                containerHeight: parent.height
                                progressIndicatorBackground: "transparent"
                                iconContainerBackground: "transparent"
                                statusText.visible: false
                                progressIcon: btnStatusIndicator.working
                            }
                        }
                        onClicked: {

                            exportStarted();

                            exportDetails.currentExportRequest = {}
                            exportDetails.currentExportRequest.service = currentTileService["title"];
                            exportDetails.currentExportRequest.extent = JSON.stringify(mapViewPlus.getCurrentGeometry());
                            if(mapViewPlus.drawMultipath){
                                exportDetails.currentExportRequest.buffer = exportDetails.currentBufferInMeters;
                            }
                            exportDetails.currentLevels = (exportDetails.tpkZoomLevels > 0) ? "0-" + exportDetails.tpkZoomLevels.toString() : "0";
                            exportDetails.currentExportRequest.levels = exportDetails.currentLevels

                            var outFileName = (exportDetails.currentExportTitle != "") ? exportDetails.currentExportTitle : "tpk_export"

                            var outPortalOptions = null;

                            if(exportDetails.uploadToPortal){
                                outPortalOptions = {};
                                outPortalOptions.uploadToPortal = true;
                                outPortalOptions.serviceTitle = (exportDetails.tpkTitle !== "") ? exportDetails.tpkTitle : "NoTitle";
                                outPortalOptions.serviceDescription = (exportDetails.tpkDescription !== "") ? exportDetails.tpkDescription : "No Description";
                            }

                            exportDetails.currentExportRequest.serviceTitle = (exportDetails.tpkTitle !== "") ? exportDetails.tpkTitle : "NoTitle";
                            exportDetails.currentExportRequest.serviceDescription = (exportDetails.tpkDescription !== "") ? exportDetails.tpkDescription : "No Description";

                            var tileService = {
                                "url": currentTileService.url,
                                "usesToken": currentTileService.useTokenToAccess
                            }

                            tpkExport.exportTiles(tileService, exportDetails.currentLevels, mapViewPlus.getCurrentGeometry(), exportDetails.currentBufferInMeters, outFileName, exportDetails.currentSaveToLocation, outPortalOptions);

                            mapViewPlus.clearMap();
                            }
                        }
                    }

                //--------------------------------------------------------------

                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 140 * AppFramework.displayScaleFactor
                    color: "#fff"
                    enabled: exporting && !tpkUpdate.active && !getPKInfo.active
                    visible: exporting && !tpkUpdate.active && !getPKInfo.active

                    Button {
                        id: cancelExport
                        anchors.fill: parent
                        anchors.margins: 10 * AppFramework.displayScaleFactor

                        style: ButtonStyle {
                            background: Rectangle {
                                anchors.fill: parent
                                color: config.buttonStates(control, "clear")
                                radius: app.info.properties.mainButtonRadius
                                border.width: (control.enabled) ? app.info.properties.mainButtonBorderWidth : 0
                                border.color: "#fff"
                            }
                        }

                        Text {
                            color: app.info.properties.mainButtonBackgroundColor
                            anchors.centerIn: parent
                            textFormat: Text.RichText
                            text: "Cancel"
                            font.pointSize: config.baseFontSizePoint
                            font.family: notoRegular.name
                        }

                        onClicked: {

                            if(tpkExport.active){
                                tpkExport.cancel();
                            }

                            if(tpkUpload.active){
                                tpkUpload.cancel();
                            }
                        }
                    }
                }

                }
            }
        }
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    TilePackageExport {
        id: tpkExport
        portal: exportView.portal

        onExportGeometryTransformStarted: {
            estimateSizeProgressIndicator.show();
            estimateSizeProgressIndicator.progressIcon = estimateSizeProgressIndicator.working;
            estimateSizeProgressIndicator.progressText = "Creating buffer geometry";
        }

        onExportEstimateSizeStarted: {
            estimateSizeProgressIndicator.show();
            estimateSizeProgressIndicator.progressIcon = estimateSizeProgressIndicator.working;
            estimateSizeProgressIndicator.progressText = "Estimating tile package size.";
        }

        onExportEstimateSizeComplete: {
            estimateSizeProgressIndicator.progressIcon = estimateSizeProgressIndicator.success;
            estimateSizeProgressIndicator.progressText = "Estimated Size: " + response.sizeInMegabytes + "MB, Number of Tiles: " + response.numberOfTiles;
            exportDetails.currentExportRequest.package_size = response.sizeInMegabytes;
            exportDetails.currentExportRequest.number_of_tiles = response.numberOfTiles;
        }

        onExportStarted: {
            exportCompleteProgressIndicator.progressIcon = exportCompleteProgressIndicator.working;
            exportCompleteProgressIndicator.progressText = "Export Started";
            exportCompleteProgressIndicator.show();
        }

        onExportComplete: {
            exportDetails.currentExportRequest.download_url = itemUrl;
            exportDetails.currentExportRequest.export_date = Date.now();
            exportCompleteProgressIndicator.progressIcon = exportCompleteProgressIndicator.success;
            exportCompleteProgressIndicator.progressText = "Export Complete.";
        }

        onExportError: {
            exportStatusIndicator.messageType = exportStatusIndicator.error;
            exportStatusIndicator.message = "Export Failed. " + message
            exportStatusIndicator.show();
            try{
                throw new Error(message);
            }
            catch(e){
                appMetrics.reportError(e)
            }
            exportView.exportComplete();
        }

        onExportDownloadStarted: {
            downloadProgressIndicator.progressIcon = downloadProgressIndicator.working;
            downloadProgressIndicator.progressText = "Downloading.";
            downloadProgressIndicator.show();
        }

        onExportDownloadComplete: {
            downloadProgressIndicator.progressIcon = downloadProgressIndicator.success;
            downloadProgressIndicator.progressText = "Download Complete.";
            exportDetails.currentExportRequest.filepath = file.path;
            exportDetails.currentExportRequest.filename = file.name
            try{
                history.writeHistory(history.exportHistoryKey, exportDetails.currentExportRequest);
            }
            catch(error){
                appMetrics.reportError(error)
            }
            finally{
                if(!exportDetails.uploadToPortal){
                    exportStatusIndicator.messageType = exportStatusIndicator.success;
                    if(calledFromAnotherApp && dlr.successCallback !== ""){
                        exportStatusIndicator.message = "Complete. <a href='%1?isShared=%2&isOnline=%3&localPath=%4'>Return to %5</a>".arg(dlr.successCallback).arg("false").arg("false").arg(encodeURI(file.path)).arg(dlr.callingApplication);
                    }else{
                        exportStatusIndicator.message = "Downloaded to %1".arg(file.path);
                    }
                    exportView.exportComplete();
                    exportStatusIndicator.show();
                }
                else{
                    tpkUpload.upload(file.path, currentItemPortalOptions.serviceTitle, currentItemPortalOptions.serviceDescription)
                }
            }
        }

        onExportCancelled: {
            exportStatusIndicator.messageType = exportStatusIndicator.info;
            exportStatusIndicator.message = "Export Cancelled.";
            exportStatusIndicator.show();
            exportView.exportComplete();
        }

    }

    //--------------------------------------------------------------------------

    TilePackageUpload {

        id: tpkUpload
        portal: exportView.portal

        onSrCheckComplete: {
        }

        onUploadStarted: {
            uploading = true;
            uploadProgressIndicator.progressIcon = downloadProgressIndicator.working;
            uploadProgressIndicator.progressText = "Uploading to portal.";
            uploadProgressIndicator.show();
        }

        onUploadComplete: {
            uploading = false;
            try{
                history.writeHistory(history.uploadHistoryKey,
                            {   "transaction_date": Date.now(),
                                "title": exportDetails.tpkTitle,
                                "description": (exportDetails.tpkDescription !== "") ? exportDetails.tpkDescription : "Created via Tile Export. Update Description using Browse or online at link below.",
                                "service_url" : portal.owningSystemUrl + "/home/item.html?id=" + id
                            });
             }
            catch(error){
                appMetrics.reportError(error);
            }
            finally{

                exportDetails.currentExportRequest.service_url = portal.owningSystemUrl + "/home/item.html?id=" + id;

                if(exportDetails.currentSharing !== ""){
                    uploadProgressIndicator.progressText = "Sharing item.";
                    tpkUpdate.share(id, exportDetails.currentSharing);
                }
                else{
                    uploadProgressIndicator.progressIcon = downloadProgressIndicator.success;
                    uploadProgressIndicator.progressText = "Uploaded.";
                    exportStatusIndicator.messageType = exportStatusIndicator.success;
                    if(calledFromAnotherApp && dlr.successCallback !== ""){
                         exportStatusIndicator.message = "Complete. <a href='%1?isShared=%2&isOnline=%3&itemId=%4'>Return to %5</a>".arg(dlr.successCallback).arg("false").arg("true").arg(id).arg(dlr.callingApplication);
                    }
                    else{
                        exportStatusIndicator.message = "Uploaded. <a href=\"" + exportDetails.currentExportRequest.service_url + "\">See Tile Package Item</a>";
                    }
                    exportStatusIndicator.show();
                    exportView.exportComplete();
                }

                try{
                   tpkExport.deleteLocalTilePackage(exportDetails.currentExportRequest.filepath);
                   getPKInfo.get(exportDetails.currentExportRequest.filename, id);
                }
                catch(e){
                    console.log(e);
                }
            }
        }

        onUploadCancelled: {
            uploading = false;
            exportStatusIndicator.messageType = exportStatusIndicator.info;
            exportStatusIndicator.message = "Export Upload Cancelled.";
            exportStatusIndicator.show();
            exportView.exportComplete();
            exportView.exportComplete();
        }

        onUploadFailed: {
            uploading = false;

            var failMessage = "onUploadFailed"

            if(error.message.indexOf("already exists") > -1){
                failMessage = "A tpk file with that name already exists.";
            }

            exportStatusIndicator.messageType = exportStatusIndicator.error;
            exportStatusIndicator.message = "Export Upload Failed. " + failMessage;

            if(error.message.indexOf("Cancelled") > -1){
                exportStatusIndicator.messageType = exportStatusIndicator.info;
                exportStatusIndicator.message = "Export Upload Cancelled";
            }

            try{
                throw new Error(failMessage);
            }
            catch(e){
                appMetrics.reportError(e)
            }

            exportStatusIndicator.show();
            exportView.exportComplete();
        }

        onUploadError: {
            uploading = false;
            var failMessage = "onUploadError"
            exportStatusIndicator.messageType = exportStatusIndicator.error;
            exportStatusIndicator.message = "Export Upload Failed. " + failMessage;
            exportStatusIndicator.show();
            exportView.exportComplete();

            try{
                throw new Error(error);
            }
            catch(e){
                appMetrics.reportError(e)
            }
        }

        onAbortedChanged: {
            if(aborted){
                uploading = false;
                uploadProgressIndicator.progressIcon = downloadProgressIndicator.failed;
                uploadProgressIndicator.progressText = "Cancelling Upload.";
            }
        }
    }

    //--------------------------------------------------------------------------

    TilePackageUpdate{
        id: tpkUpdate
        portal: exportView.portal
        onShared: {
            uploadProgressIndicator.progressIcon = downloadProgressIndicator.success;
            uploadProgressIndicator.progressText = "Shared";
            exportStatusIndicator.messageType = exportStatusIndicator.success;
            if(calledFromAnotherApp && dlr.successCallback !== ""){
                exportStatusIndicator.message = "Complete. <a href='%1?isShared=%2&isOnline=%3&itemId=%4'>Return to %5</a>".arg(dlr.successCallback).arg("true").arg("true").arg(itemId).arg(dlr.callingApplication);
            }else{
                exportStatusIndicator.message = "Uploaded and Shared. <a href=\"" + exportDetails.currentExportRequest.service_url + "\">See Tile Package Item</a>";
            }
            exportStatusIndicator.show();
            exportView.exportComplete();
        }
    }

    //--------------------------------------------------------------------------

    TilePackageEstimateSize{
        id:tpkEstimateSize

        onCalculationComplete: {
            var inMb = (parseFloat(estimate.bytes,10) / 1048576).toFixed(2);
            var numTiles = estimate.tiles < 100000 ? ("~" + estimate.tiles) : "100,000+";
            var mb = inMb < 1000 ? ("~" + inMb + "Mb") : "1Gb+";
            tilePackageSizeEstimate.text = "Tiles: %1 Size: %2".arg(numTiles).arg(mb);
        }
    }

    //--------------------------------------------------------------------------

    CoordinateConverter{
        id: coordConverter
    }

    //--------------------------------------------------------------------------

    TilePackageGetPKInfo {
        id: getPKInfo
        path: (tpkExport.userDefinedTpkFolder === null) ? tpkExport.defaultTpkFolder + "/" : tpkExport.userDefinedTpkFolder + "/" //exportDetails.currentSaveToLocation + "/"
        portal: exportView.portal
        onComplete: {
            //if(!tpkUpdate.active){
            //    uploading = false;
            //    exportView.exportComplete();
            //}
        }
    }

    // -------------------------------------------------------------------------

    HistoryManager{
        id: history
    }

    // -------------------------------------------------------------------------

    PropertyAnimation{
        id:fader
        from: 1
        to: 0
        duration: 1000
        property: "opacity"
        running: false
        easing.type: Easing.OutCubic
        target: tpkExportStatusOverlay

        onStopped: {
            tpkExportStatusOverlay.visible = false;
            estimateSizeProgressIndicator.hide();
            exportCompleteProgressIndicator.hide();
            downloadProgressIndicator.hide();
            uploadProgressIndicator.hide();
            exportErrorProgressIndicator.hide();
        }
    }

    //--------------------------------------------------------------------------

    Connections{
        target: app

        onIncomingUrlChanged: {
            if(mapViewPlus.userDrawnExtent){
                mapViewPlus.clearExtentButton.clicked();
            }
        }
    }

    // METHODS /////////////////////////////////////////////////////////////////

    function _displayCoordinates(coords){
        var latDir = coords.latitude > 0 ? "N" : "S";
        var longDir = coords.longitude > 0 ? "E" : "W";
        currentCursorLatLong.text = "%1%2  %3%4".arg(Math.abs(coords.latitude)).arg(latDir).arg(Math.abs(coords.longitude)).arg(longDir);
    }

    //--------------------------------------------------------------------------

    function extractDefaultTPKTitle(service_title){
        var defaultTitle;

        if(service_title.indexOf("(") > -1){
            defaultTitle = service_title.substring(0, service_title.indexOf("("));
            defaultTitle = defaultTitle.replace(/_/g, " ");
        }
        else{
             defaultTitle = service_title.substring(0,30);
        }
        return defaultTitle.trim() + " TPK";
    }

    //--------------------------------------------------------------------------

    function _uiEntryElementStates(control){
        if(!control.enabled){
            return config.formElementDisabledBackground;
        }
        else{
            return config.formElementBackground;
        }
    }

    // END /////////////////////////////////////////////////////////////////////
}
