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

import QtQuick 2.7
import QtQuick.Controls 2.1
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
import "Controls" as Controls
import "singletons" as Singletons
//------------------------------------------------------------------------------

Item {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: exportView

    property Portal portal
    property bool exporting: false
    property bool uploading: false
    property var currentTileService: null
    property ListModel availableServices
    property int currentTileIndex: 0

    signal exportStarted()
    signal exportComplete()

//    onAvailableServicesChanged: {
//        exportDetails.tileServicesSimpleListModel.clear();
//        for (var x = 0; x < availableServices.count; x++) {
//            console.log(availableServices[x]);
//            var service = availableServices[x];
//            exportDetails.tileServicesSimpleListModel.append({title: service.title})
//        }
//    }

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

    StackView.onActivating: {
        mainView.appToolBar.backButtonEnabled = true;
        mainView.appToolBar.backButtonVisible = true;
        mainView.appToolBar.historyButtonEnabled = true;
        mainView.appToolBar.toolBarTitleLabel = Singletons.Strings.createNewTilePackage
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
        tilePackageSizeEstimate.text = Singletons.Strings.tilesXSizeX.arg("--").arg("--");
    }

    // UI //////////////////////////////////////////////////////////////////////

    Rectangle {
        anchors.fill: parent
        color: "#eee"

        ColumnLayout {
            id: exportTpkViewColumnLayout
            anchors.fill: parent
            spacing: sf(1)

        // MAP AND DETAILS SECTION /////////////////////////////////////////////

        Rectangle {
            id: mapAndDetailsSection
            Layout.fillWidth: true
            Layout.fillHeight: true
            enabled: (exporting) ? false : true
            clip: true
            color: Singletons.Colors.mediumGray

            RowLayout {
                anchors.fill: parent
                spacing: sf(1)

                // MAP SECTION /////////////////////////////////////////////////

                Rectangle {
                    color: "#fff"
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout{
                        anchors.fill: parent
                        spacing: 0

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
                                    _displayCoordinates(position.coordinate);
                                }
                                else{
                                    currentCursorLatLong.text = "-- --";
                                }
                            }

                            onDrawingCleared: {
                                tilePackageSizeEstimate.text = Singletons.Strings.tilesXSizeX.arg("--").arg("--");
                            }

                            onDrawingStarted: {
                            }

                            onDrawingFinished: {
                                if(mapViewPlus.topLeft !== null && mapViewPlus.bottomRight !== null && mapViewPlus.geometryType !== Singletons.Constants.kMultipath /*"multipath"*/){
                                    var tlAsXY = coordConverter.lngLatToXY(positionToArray(mapViewPlus.topLeft));
                                    var brAsXY = coordConverter.lngLatToXY(positionToArray(mapViewPlus.bottomRight));
                                    //tpkEstimateSize.calculate(tlAsXY, brAsXY, exportDetails.tpkZoomLevels);
                                    tpkEstimateSize.calculateForRange(tlAsXY, brAsXY, exportDetails.tpkBottomZoomLevel.value, exportDetails.tpkTopZoomLevel.value);

                                }
                            }

                            onDrawingError: {
                                exportStatusIndicator.messageType = exportStatusIndicator.error;
                                exportStatusIndicator.message = error;
                                exportStatusIndicator.show();
                            }
                        }

                        // MAP TOOL BAR ////////////////////////////////////////

                        Rectangle {
                            id: mapInfoToolbar
                            Layout.preferredHeight: sf(50)
                            Layout.fillWidth: true
                            color:Singletons.Config.subtleBackground

                            RowLayout {
                                anchors.fill: parent
                                spacing: sf(1)

                                //----------------------------------------------

                                Rectangle {
                                    id: zoomLevelIndicatorContainer
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: sf(140)

                                    ColumnLayout{
                                        spacing: 0
                                        anchors.fill: parent

                                        Rectangle{
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height / 2
                                            color: app.info.properties.toolBarBackgroundColor

                                            Text{
                                                anchors.fill: parent
                                                text: Singletons.Strings.zoomLevel
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                color: "#fff"
                                                font.pointSize: Singletons.Config.smallFontSizePoint
                                                font.family: notoRegular

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
                                                font.family: notoRegular

                                                Accessible.role: Accessible.Indicator
                                                Accessible.name: text
                                                Accessible.description: Singletons.Strings.zoomLevelDesc
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
                                                text: Singletons.Strings.cursorCoord
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                color: "#fff"
                                                font.pointSize: Singletons.Config.smallFontSizePoint
                                                font.family: notoRegular

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
                                                font.family: notoRegular

                                                Accessible.role: Accessible.Indicator
                                                Accessible.name: text
                                                Accessible.description: Singletons.Strings.cursorCoordDesc
                                            }
                                        }
                                    }
                                }

                                //----------------------------------------------

                                Rectangle {
                                    id: tilePackageSizeEstimateContainer
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    ColumnLayout {
                                        spacing:0
                                        anchors.fill: parent

                                        Rectangle{
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height / 2
                                            color: app.info.properties.toolBarBackgroundColor

                                            Text{
                                                anchors.fill: parent
                                                text: Singletons.Strings.estimatedOutputSize
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                color: "#fff"
                                                font.pointSize: Singletons.Config.smallFontSizePoint
                                                font.family: notoRegular

                                                Accessible.role: Accessible.Heading
                                                Accessible.name: text
                                            }
                                        }

                                        Rectangle{
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            Text{
                                                anchors.fill: parent
                                                visible: mapViewPlus.geometryType === Singletons.Constants.kMultipath // "multipath"
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                text: Singletons.Strings.notAvailableWithPaths
                                                font.family: notoRegular

                                                Accessible.ignored: mapViewPlus.geometryType !== Singletons.Constants.kMultipath // "multipath"
                                                Accessible.role: Accessible.Indicator
                                                Accessible.name: text
                                                Accessible.description: Singletons.Strings.estimatedOutputSizeDesc

                                            }

                                            Text{
                                                id:tilePackageSizeEstimate
                                                visible: mapViewPlus.geometryType !== Singletons.Constants.kMultipath // "multipath"
                                                anchors.fill: parent
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                text: "Tiles: -- Size: --"
                                                font.family: notoRegular

                                                Accessible.ignored: mapViewPlus.geometryType === Singletons.Constants.kMultipath // "multipath"
                                                Accessible.role: Accessible.Indicator
                                                Accessible.name: text
                                                Accessible.description: Singletons.Strings.estimatedOutputSizeDesc
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
                    Layout.preferredWidth: sf(300)
                    color: "#fff"
                    Accessible.role: Accessible.Pane

                   DetailsForm {
                        id: exportDetails
                        height: parent.height
                        width: parent.width
                        anchors.fill: parent
                        enabled: true
                        exportOnly: true
                        exportAndUpload: true
                        exportPathBuffering: mapViewPlus.geometryType === "multipath"
                        currentTileService: exportView.currentTileService
                        tileServicesSimpleListModel: availableServices
                        currentTileIndex: exportView.currentTileIndex
                        tpkTitle: exportView.extractDefaultTPKTitle(exportView.currentTileService.title)

                        onChangeTileService: {
                            exportView.currentTileIndex = index;
                            exportView.currentTileService = availableServices.get(index);
                        }

                        onExportZoomLevelsChanged: {
                            if(mapViewPlus.topLeft !== null && mapViewPlus.bottomRight !== null){
                                var tlAsXY = coordConverter.lngLatToXY(positionToArray(mapViewPlus.topLeft));
                                var brAsXY = coordConverter.lngLatToXY(positionToArray(mapViewPlus.bottomRight));
                                //tpkEstimateSize.calculate(tlAsXY, brAsXY, exportDetails.tpkZoomLevels);
                                tpkEstimateSize.calculateForRange(tlAsXY, brAsXY, exportDetails.tpkBottomZoomLevel.value, exportDetails.tpkTopZoomLevel.value);

                            }
                        }
                    }
                }
            }

            // EXPORT OVERLAY //////////////////////////////////////////////////

            Rectangle {
                id: tpkExportStatusOverlay
                color:"transparent"
                anchors.fill: parent
                visible: false

                Rectangle {
                    anchors.fill:parent
                    opacity: .9
                    color: Singletons.Config.subtleBackground
                    z: 100
                }

                ColumnLayout {
                    id: exportStatus
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: sf(10)
                    z: 101

                    ProgressIndicator {
                        id: estimateSizeProgressIndicator
                        statusTextFontSize: Singletons.Config.smallFontSizePoint
                        statusTextMinimumFontSize: 6
                        statusTextLeftMargin: sf(10)
                        iconContainerLeftMargin: sf(5)
                        iconContainerHeight: this.containerHeight - sf(5)
                        Layout.fillWidth: true
                        visible: false
                    }
                    ProgressIndicator{
                        id:exportCompleteProgressIndicator
                        statusTextFontSize:Singletons.Config.smallFontSizePoint
                        statusTextMinimumFontSize: 6
                        statusTextLeftMargin: sf(10)
                        iconContainerLeftMargin: sf(5)
                        iconContainerHeight: this.containerHeight - sf(5)
                        Layout.fillWidth: true
                        visible: false
                    }

                    ProgressIndicator{
                        id: downloadProgressIndicator
                        statusTextFontSize:Singletons.Config.smallFontSizePoint
                        statusTextMinimumFontSize: 6
                        statusTextLeftMargin: sf(10)
                        iconContainerLeftMargin: sf(5)
                        iconContainerHeight: this.containerHeight - sf(5)
                        Layout.fillWidth: true
                        visible: false
                    }

                    ProgressIndicator{
                        id: uploadProgressIndicator
                        statusTextFontSize:Singletons.Config.smallFontSizePoint
                        statusTextMinimumFontSize: 6
                        statusTextLeftMargin: sf(10)
                        iconContainerLeftMargin: sf(5)
                        iconContainerHeight: this.containerHeight - sf(5)
                        Layout.fillWidth: true
                        visible: false
                    }

                    ProgressIndicator{
                        id: exportErrorProgressIndicator
                        statusTextFontSize:Singletons.Config.smallFontSizePoint
                        statusTextMinimumFontSize: 6
                        statusTextLeftMargin: sf(10)
                        iconContainerLeftMargin: sf(5)
                        iconContainerHeight: this.containerHeight - sf(5)
                        Layout.fillWidth: true
                        visible: false
                    }
                }
            }
        }

        // BOTTOM TASK BAR /////////////////////////////////////////////////////

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: sf(60)
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
                        anchors.margins: sf(10)

                        StatusIndicator{
                            id: exportStatusIndicator
                            anchors.fill: parent
                            containerHeight: parent.height
                            hideAutomatically: true
                            statusTextFontSize: Singletons.Config.baseFontSizePoint
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
                    Layout.preferredWidth: sf(190)
                    color: "#fff"
                    visible: !exporting

                    Button {
                        id: exportTPKBtn
                        anchors.fill: parent
                        anchors.margins: sf(10)
                        enabled: (exportDetails.tpkTitle !== "" /*tpkTitleTextField.text !== ""*/ && mapViewPlus.userDrawnExtent) ? true : false
                        background: Rectangle {
                            anchors.fill: parent
                            color: Singletons.Config.buttonStates(parent)
                            radius: app.info.properties.mainButtonRadius
                            border.width: parent.enabled ? app.info.properties.mainButtonBorderWidth : 0
                            border.color: app.info.properties.mainButtonBorderColor
                        }

                        RowLayout{
                            spacing: 0
                            anchors.fill: parent

                            Text {
                                id: exportTPKBtnText
                                color: app.info.properties.mainButtonFontColor
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                textFormat: Text.RichText
                                text: (!exporting) ? Singletons.Strings.createTilePackage : Singletons.Strings.create
                                font.pointSize: Singletons.Config.baseFontSizePoint
                                font.family: notoRegular
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
                            exportDetails.currentLevels = (exportDetails.tpkTopZoomLevel.value > 0) ? "%1-%2".arg(exportDetails.tpkBottomZoomLevel.value.toString()).arg(exportDetails.tpkTopZoomLevel.value.toString()) : "0";
                            exportDetails.currentExportRequest.levels = exportDetails.currentLevels

                            var outFileName = (exportDetails.currentExportTitle != "") ? exportDetails.currentExportTitle : "tpk_export"

                            var outPortalOptions = null;

                            if(exportDetails.uploadToPortal){
                                outPortalOptions = {};
                                outPortalOptions.uploadToPortal = true;
                                outPortalOptions.serviceTitle = (exportDetails.tpkTitle !== "") ? exportDetails.tpkTitle : Singletons.Strings.noTitle;
                                outPortalOptions.serviceDescription = (exportDetails.tpkDescription !== "") ? exportDetails.tpkDescription : Singletons.Strings.noDesc;
                            }

                            exportDetails.currentExportRequest.serviceTitle = (exportDetails.tpkTitle !== "") ? exportDetails.tpkTitle : Singletons.Strings.noTitle;
                            exportDetails.currentExportRequest.serviceDescription = (exportDetails.tpkDescription !== "") ? exportDetails.tpkDescription : Singletons.Strings.noDesc;

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
                    Layout.preferredWidth: sf(140)
                    color: "#fff"
                    enabled: exporting && !tpkUpdate.active && !getPKInfo.active
                    visible: exporting && !tpkUpdate.active && !getPKInfo.active

                    Button {
                        id: cancelExport
                        anchors.fill: parent
                        anchors.margins: sf(10)

                        background: Rectangle {
                            anchors.fill: parent
                            color: Singletons.Config.buttonStates(parent, "clear")
                            radius: app.info.properties.mainButtonRadius
                            border.width: parent.enabled ? app.info.properties.mainButtonBorderWidth : 0
                            border.color: "#fff"
                        }

                        Text {
                            color: app.info.properties.mainButtonBackgroundColor
                            anchors.centerIn: parent
                            textFormat: Text.RichText
                            text: Singletons.Strings.cancel
                            font.pointSize: Singletons.Config.baseFontSizePoint
                            font.family: notoRegular
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
            estimateSizeProgressIndicator.progressText = Singletons.Strings.creatingBufferGeometry;
        }

        onExportEstimateSizeStarted: {
            estimateSizeProgressIndicator.show();
            estimateSizeProgressIndicator.progressIcon = estimateSizeProgressIndicator.working;
            estimateSizeProgressIndicator.progressText = Singletons.Strings.estimatingTPKSize;
        }

        onExportEstimateSizeComplete: {
            estimateSizeProgressIndicator.progressIcon = estimateSizeProgressIndicator.success;
            estimateSizeProgressIndicator.progressText = Singletons.Strings.estimatedSizeXNumOfTilesX.arg(response.sizeInMegabytes).arg(response.numberOfTiles) //"Estimated Size: " + response.sizeInMegabytes + "MB, Number of Tiles: " + response.numberOfTiles;
            exportDetails.currentExportRequest.package_size = response.sizeInMegabytes;
            exportDetails.currentExportRequest.number_of_tiles = response.numberOfTiles;
        }

        onExportStarted: {
            exportCompleteProgressIndicator.progressIcon = exportCompleteProgressIndicator.working;
            exportCompleteProgressIndicator.progressText = Singletons.Strings.exportStarted;
            exportCompleteProgressIndicator.show();
        }

        onExportComplete: {
            exportDetails.currentExportRequest.download_url = itemUrl;
            exportDetails.currentExportRequest.export_date = Date.now();
            exportCompleteProgressIndicator.progressIcon = exportCompleteProgressIndicator.success;
            exportCompleteProgressIndicator.progressText = Singletons.Strings.exportComplete;
        }

        onExportError: {
            exportStatusIndicator.messageType = exportStatusIndicator.error;
            exportStatusIndicator.message = Singletons.Strings.exportFailed +  " " + message;
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
            downloadProgressIndicator.progressText = Singletons.Strings.downloading; //"Downloading.";
            downloadProgressIndicator.show();
        }

        onExportDownloadComplete: {
            downloadProgressIndicator.progressIcon = downloadProgressIndicator.success;
            downloadProgressIndicator.progressText = Singletons.Strings.downloadComplete; // "Download Complete.";
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
                        exportStatusIndicator.message = Singletons.Strings.completeReturnToX.arg(dlr.successCallback).arg("false").arg("false").arg(encodeURI(file.path)).arg(dlr.callingApplication); //"Complete. <a href='%1?isShared=%2&isOnline=%3&localPath=%4'>Return to %5</a>".arg(dlr.successCallback).arg("false").arg("false").arg(encodeURI(file.path)).arg(dlr.callingApplication);
                    }else{
                        exportStatusIndicator.message = Singletons.Strings.downloadedToX.arg(file.path);
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
            exportStatusIndicator.message = Singletons.Strings.exportCancelled; //"Export Cancelled.";
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
            uploadProgressIndicator.progressText = Singletons.Strings.uploadingToPortal; // "Uploading to portal.";
            uploadProgressIndicator.show();
        }

        onUploadComplete: {
            uploading = false;
            try{
                history.writeHistory(history.uploadHistoryKey,
                            {   "transaction_date": Date.now(),
                                "title": exportDetails.tpkTitle,
                                "description": (exportDetails.tpkDescription !== "") ? exportDetails.tpkDescription : Singletons.Strings.defaultTPKDesc,
                                "service_url" : portal.owningSystemUrl + "/home/item.html?id=" + id
                            });
             }
            catch(error){
                appMetrics.reportError(error);
            }
            finally{

                exportDetails.currentExportRequest.service_url = portal.owningSystemUrl + "/home/item.html?id=" + id;

                if(exportDetails.currentSharing !== ""){
                    uploadProgressIndicator.progressText = Singletons.Strings.sharingItem;
                    tpkUpdate.share(id, exportDetails.currentSharing);
                }
                else{
                    uploadProgressIndicator.progressIcon = downloadProgressIndicator.success;
                    uploadProgressIndicator.progressText = Singletons.Strings.uploaded;
                    exportStatusIndicator.messageType = exportStatusIndicator.success;
                    if(calledFromAnotherApp && dlr.successCallback !== ""){
                         exportStatusIndicator.message = Singletons.Strings.completeReturnToX.arg(dlr.successCallback).arg("false").arg("true").arg(id).arg(dlr.callingApplication); //"Complete. <a href='%1?isShared=%2&isOnline=%3&itemId=%4'>Return to %5</a>".arg(dlr.successCallback).arg("false").arg("true").arg(id).arg(dlr.callingApplication);
                    }
                    else{
                        exportStatusIndicator.message = Singletons.Strings.uploadedSeeX.arg(exportDetails.currentExportRequest.service_url) //"Uploaded. <a href=\"" + exportDetails.currentExportRequest.service_url + "\">See Tile Package Item</a>";
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
            exportStatusIndicator.message = Singletons.Strings.exportUploadCancelled //"Export Upload Cancelled.";
            exportStatusIndicator.show();
            exportView.exportComplete();
            exportView.exportComplete();
        }

        onUploadFailed: {
            uploading = false;

            var failMessage = "onUploadFailed"

            if(error.message.indexOf("already exists") > -1){
                failMessage = Singletons.Strings.tpkWithThatNameAlreadyExistsError;
            }

            exportStatusIndicator.messageType = exportStatusIndicator.error;
            exportStatusIndicator.message = Singletons.Strings.exportUploadFailed + " " + failMessage;

            if(error.message.indexOf("Cancelled") > -1){
                exportStatusIndicator.messageType = exportStatusIndicator.info;
                exportStatusIndicator.message = Singletons.Strings.exportUploadCancelled;
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
            exportStatusIndicator.message = Singletons.Strings.exportUploadFailed + " " + failMessage;
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
                uploadProgressIndicator.progressText = Singletons.Strings.cancellingUpload;
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
                exportStatusIndicator.message = Singletons.Strings.completeReturnToX.arg(dlr.successCallback).arg("true").arg("true").arg(itemId).arg(dlr.callingApplication); //"Complete. <a href='%1?isShared=%2&isOnline=%3&itemId=%4'>Return to %5</a>".arg(dlr.successCallback).arg("true").arg("true").arg(itemId).arg(dlr.callingApplication);
            }else{
                exportStatusIndicator.message = Singletons.Strings.uploadingAndSharedSeeX.arg(exportDetails.currentExportRequest.service_url); //"Uploaded and Shared. <a href=\"" + exportDetails.currentExportRequest.service_url + "\">See Tile Package Item</a>";
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
            tilePackageSizeEstimate.text = Singletons.Strings.tilesXSizeX.arg(numTiles).arg(mb); //"Tiles: %1 Size: %2".arg(numTiles).arg(mb);
        }
    }

    //--------------------------------------------------------------------------

    CoordinateConverter{
        id: coordConverter
    }

    //--------------------------------------------------------------------------

    AvailableServicesModel {
        id: asm
        portal: exportView.portal
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
            return Singletons.Config.formElementDisabledBackground;
        }
        else{
            return Singletons.Config.formElementBackground;
        }
    }

    //--------------------------------------------------------------------------

    function positionToArray(position){
        return [position.longitude, position.latitude];
    }

    // END /////////////////////////////////////////////////////////////////////
}
