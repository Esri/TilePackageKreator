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
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtLocation 5.3
import QtPositioning 5.3
import QtGraphicalEffects 1.0
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Sql 1.0
//------------------------------------------------------------------------------
import "../Portal"
import "../singletons" as Singletons
import "../Controls" as Controls
import "../"
//------------------------------------------------------------------------------

Item {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: mapViewPlus

    objectName: "MapViewPlus"
    property Portal mapViewPlusPortal

    // Configurable Properties -------------------------------------------------

    property string drawnExtentOutlineColor: Singletons.Colors.drawnExtentOutlineColor
    property string drawingExtentFillColor: Singletons.Colors.drawingExtentFillColor
    property int mapSpatialReference: Singletons.Constants.kQtMapSpatialReference
    property double mapDefaultLat: 0
    property double mapDefaultLong: 0
    property var mapDefaultCenter: { "lat": mapDefaultLat, "long": mapDefaultLong }
    property int mapDefaultZoomLevel: 5
    property var mapTileService: null

    // Internal Properties -----------------------------------------------------

    property bool drawing: false
    property var drawingStartCoord: {'x': null, 'y': null}
    property var drawingEndCoord: {'x': null, 'y': null}
    property var pathCoordinates: []
    property var drawingHistory: []
    property var topLeft: null
    property var bottomRight: null
    property bool userDrawnExtent: false
    property bool cursorIsOffMap: true
    property bool allowMapToPan: false
    property bool mapTileServiceUsesToken: true
    property bool historyAvailable: false
    property SqlQueryModel userBookmarks

    property string geometryType: ""
    property bool drawEnvelope: geometryType === Singletons.Constants.kEnvelope ? true : false
    property bool drawPolygon: geometryType === Singletons.Constants.kPolygon ? true : false
    property bool drawMultipath: geometryType === Singletons.Constants.kMultipath ? true : false

    readonly property alias map: previewMap.map
    readonly property alias clearExtentButton: clearExtentBtn
    property alias geoJsonHelper: geoJsonHelper

    signal drawingStarted()
    signal drawingFinished()
    signal drawingCleared()
    signal drawingError(string error)
    signal zoomLevelChanged(var level)
    signal positionChanged(var position)
    signal redraw(var data)
    signal basemapLoaded()

    Component.onCompleted: {
        userBookmarks = appDatabase.read("SELECT * FROM 'bookmarks' WHERE user IS '%1'".arg(portal.user.email));
    }

    // SIGNAL IMPLEMENTATION ///////////////////////////////////////////////////

    onDrawingStarted: {
        drawing = true;
        resetProperties();
        clearDrawingCanvas();

        if (clearExtentMapItem.visible) {
            clearExtentBtn.clicked();
        }
        else if (previewMap.map.mapItems.length > 0) {
            clearMap();
        }
        else {
        }
    }

    //--------------------------------------------------------------------------

    onRedraw: {
        drawingStarted();
        if (data.type === Singletons.Constants.kMultipath) {
            pathCoordinates = data.geometry;
            userDrawnExtent = true;
            geometryType = Singletons.Constants.kMultipath;
            addMultipathToMap(Singletons.Constants.kDrawFinal);
        }
        if (data.type === Singletons.Constants.kPolygon) {
            pathCoordinates = data.geometry;
            userDrawnExtent = true;
            geometryType = Singletons.Constants.kPolygon;
            addPolygonToMap(Singletons.Constants.kDrawFinal);
        }

        mapViewPlus.map.fitViewportToMapItems();
    }

    //--------------------------------------------------------------------------

    onDrawingCleared: {
        if (!drawing) {
            resetProperties();
        }
    }

    //--------------------------------------------------------------------------

    onDrawingFinished: {
        drawing = false;
        clearDrawingCanvas();
        drawingMenu.drawingRequestComplete();
        console.log("----------------onDrawingFinished:", geometryType);
    }

    // UI //////////////////////////////////////////////////////////////////////

    Item {
        id: topMenu
        width: ( parent.width < sf(1000) ) ? parent.width - sf(20) : sf(980)
        anchors.top: parent.top
        anchors.topMargin: sf(10)
        anchors.horizontalCenter: parent.horizontalCenter
        height: sf(50)

        z: previewMap.z + 3

        RowLayout {
            anchors.fill: parent
            spacing: sf(10)

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                GeoSearch {
                    id: geoSearch
                    anchors.fill: parent
                    enabled: drawing ? false : true
                    opacity: !drawing ? 1 : .4

                    //referenceCoordinate: mapViewPlus.map.center

                    onLocationClicked: {
                        mapViewPlus.map.center = location.coordinate;
                        if (mapViewPlus.map.zoomLevel < 13){
                            mapViewPlus.map.zoomLevel = 13;
                        }
                    }

                    onInputCoordinate: {
                        mapViewPlus.map.center = coordinate;
                        if (mapViewPlus.map.zoomLevel < 13){
                            mapViewPlus.map.zoomLevel = 13;
                        }
                    }
                }

                DropShadow {
                   anchors.fill: geoSearch
                   horizontalOffset: 0
                   verticalOffset: 0
                   radius: 4
                   samples: 8
                   color: "#80000000"
                   source: geoSearch
                   z: previewMap.z + 3
                   visible: !drawing
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                MapDrawingMenu {
                    id: drawingMenu
                    anchors.fill: parent
                    enabled: (drawing) ? false : true
                    drawingExists: userDrawnExtent
                    historyAvailable: mapViewPlus.historyAvailable && (previewMap.map !== null ? previewMap.map.mapItems.length <= 0 : false)
                    bookmarksAvailable: userBookmarks.count > 0

                    onDrawingRequest: {
                        if (g === Singletons.Constants.kRedraw){
                            var lastDrawing = drawingHistory[drawingHistory.length-1];
                            redraw(lastDrawing);
                        }
                        else {
                            drawingStarted();
                            geometryType = g;
                        }
                    }

                    onBookmarksRequested: {
                        bookmarksPopup.open();
                    }
                }

                DropShadow {
                       anchors.fill: drawingMenu
                       horizontalOffset: 0
                       verticalOffset: 0
                       radius: 4
                       samples: 8
                       color: "#80000000"
                       source: drawingMenu
                       z: previewMap.z + 3
                       visible: !drawing
                }
            }
        }

        Popup {
            id: bookmarksPopup
            width: sf(250)
            height: sf(200)
            x: topMenu.width - width
            y: topMenu.height

            background: Rectangle {
                color: "#fff"
                border.color: Singletons.Colors.mediumGray
                border.width: sf(1)
            }

            ListView {
                anchors.fill: parent
                id: bookmarksListView
                model: userBookmarks
                spacing: sf(2)
                delegate: bookmarkDelegate
                clip: true
            }
        }
    }

    Rectangle {
        id: mapZoomTools
        width: sf(30)
        height: (width * 2) + 1
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: sf(10)
        anchors.rightMargin: sf(10)
        z: previewMap.z + 3
        radius: sf(5)
        color: "transparent"

        ColumnLayout{
            anchors.fill: parent
            spacing: 1

            Button{
                id: mapZoomIn
                Layout.fillHeight: true
                Layout.fillWidth: true
                ToolTip.text: Singletons.Strings.zoomIn
                ToolTip.visible: hovered

                background: Rectangle {
                    anchors.fill: parent
                    color: parent.enabled ? ( parent.pressed ? "#bddbee" : "#fff" ) : "#eee"
                    border.width: parent.enabled ? app.info.properties.mainButtonBorderWidth : 0
                    border.color: parent.enabled ? app.info.properties.mainButtonBorderColor : "#ddd"
                    radius: sf(3)
                }

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    IconFont {
                        anchors.centerIn: parent
                        font.pointSize: Singletons.Config.smallFontSizePoint
                        color: app.info.properties.mainButtonBorderColor
                        icon: _icons.plus_sign
                    }
                }

                onClicked: {
                    if(map.zoomLevel < map.maximumZoomLevel){
                        map.zoomLevel = Math.floor(map.zoomLevel) + 1;
                    }
                }
            }
            Button {
                id: mapZoomOut
                Layout.fillHeight: true
                Layout.fillWidth: true
                ToolTip.text: Singletons.Strings.zoomOut
                ToolTip.visible: hovered

                background: Rectangle {
                    anchors.fill: parent
                    color: parent.enabled ? ( parent.pressed ? "#bddbee" : "#fff" ) : "#eee"
                    border.width: parent.enabled? app.info.properties.mainButtonBorderWidth : 0
                    border.color: parent.enabled ? app.info.properties.mainButtonBorderColor : "#ddd"
                    radius: sf(3)
                }

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"

                    IconFont {
                        anchors.centerIn: parent
                        font.pointSize: Singletons.Config.smallFontSizePoint
                        color: app.info.properties.mainButtonBorderColor
                        icon: _icons.minus_sign
                    }
                }
                onClicked: {
                    if(map.zoomLevel > 0 && map.zoomLevel > map.minimumZoomLevel){
                        map.zoomLevel = Math.ceil(map.zoomLevel) - 1;
                    }
                }
            }
        }
    }

    Rectangle {
        id: drawingStatusMessage
        width: sf(200)
        height: sf(30)
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: sf(10)
        z: previewMap.z + 3
        color: !drawingMenu.drawingExists ?  "#F3EDC7" : "#DDEEDB"
        opacity: !drawing ? 1 : .4

        RowLayout{
            anchors.fill: parent
            anchors.margins: sf(4)
            spacing: 0

            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: parent.height
                Layout.rightMargin: sf(8)
                opacity: .9

                IconFont {
                    anchors.centerIn: parent
                    iconSizeMultiplier: 1
                    icon: (!drawingMenu.drawing) ? ( (!drawingMenu.drawingExists) ? _icons.warning : _icons.checkmark ) : _icons.happy_face
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Text {
                    id: drawingNotice
                    anchors.fill: parent
                    font.family: notoRegular
                    font.pointSize: Singletons.Config.xSmallFontSizePoint
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    lineHeight: .8
                    text: (!drawingMenu.drawing) ? ( (!drawingMenu.drawingExists) ? Singletons.Strings.drawAnExtentOrPath : Singletons.Strings.extentOrPathDrawn ) : (geometryType === Singletons.Constants.kEnvelope) ? Singletons.Strings.drawingExtent : Singletons.Strings.drawingPath
                }
            }
        }
    }

    DropShadow {
           anchors.fill: mapZoomTools
           horizontalOffset: 0
           verticalOffset: 0
           radius: 4
           samples: 8
           color: "#80000000"
           source: mapZoomTools
           z: previewMap.z + 3
    }

    //--------------------------------------------------------------------------

    DropArea {
        id: jsonDropArea
        anchors.fill: parent
        enabled: !drawing
        onEntered: {
            // drag.urls
        }
        onDropped: {
            if (isJson(drop.urls.toString())) {
                var path = AppFramework.resolvedPath(AppFramework.resolvedUrl(drop.urls[0]));
                geoJsonHelper.parseGeometryFromFile(path);
            }
        }
    }

    //--------------------------------------------------------------------------

    Rectangle {
        id: closePolygonMouseListener
        visible: false
        enabled: closePolygonMouseListener.visible
        width: sf(16)
        height: sf(16)
        z: previewMap.z + 4
        color: "#20FFFFFF"
        radius: sf(8)

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
            ToolTip.text: qsTr("Close Polygon")
            ToolTip.visible: containsMouse
            onClicked: {
                pathCoordinates.push(pathCoordinates[0]);
                addPolygonToMap(Singletons.Constants.kDrawFinal);
            }
        }

        Connections {
            target: closePolygonMapItem

            onEnabledChanged: {
                if (closePolygonMapItem.enabled) {
                    closePolygonMouseListener.updateMyPosition();
                }
                else {
                    closePolygonMouseListener.visible = false;
                }
            }
        }

        Connections {
            target: multipathDrawingMouseArea
            onMapPanningFinished: {
                closePolygonMouseListener.updateMyPosition();
            }

            onMapPanningStarted: {
                closePolygonMouseListener.visible = false;
            }
        }

        Connections {
            target: previewMap
            onZoomLevelChanged: {
                if (drawing && drawPolygon){
                    closePolygonMouseListener.updateMyPosition();
                }
            }
        }

        function updateMyPosition() {
            var xy = latLongToScreenPosition(pathCoordinates[0].coordinate);
            closePolygonMouseListener.x = (xy.x - closePolygonMouseListener.width / 2);
            closePolygonMouseListener.y = (xy.y - closePolygonMouseListener.height / 2);
            closePolygonMouseListener.visible = true;
        }
    }

    //--------------------------------------------------------------------------

    MouseArea {
        id: multipathDrawingMouseArea
        enabled: (drawing && drawMultipath || drawing && drawPolygon) ? true : false
        focus: (drawing && drawMultipath || drawing && drawPolygon) ? true : false
        visible: (drawing && drawMultipath || drawing && drawPolygon) ? true : false
        clip: true
        anchors.fill: parent
        z: previewMap.z + 3
        cursorShape: (drawing && !allowMapToPan) ? Qt.CrossCursor : Qt.ArrowCursor
        hoverEnabled: true
        property var lastKnownPosition: null
        property bool endDrawingByDoubleClick: false
        property bool mapWasPanned: false;
        signal mapPanningFinished()
        signal mapPanningStarted()

        onEntered: {
            cursorIsOffMap = false;
        }
        onExited: {
            cursorIsOffMap = true;
        }

        onPressed: {
            /*
            if(mouse.button === Qt.RightButton){
                if(pathCoordinates.length > 1){
                    addMultipathToMap(Singletons.Constants.kDrawFinal);
                }
            }
            */

            if (mouse.modifiers === Qt.ShiftModifier) {
                mouse.accepted = false;
                allowMapToPan = true;
                multipathDrawingMouseArea.cursorShape = Qt.OpenHandCursor;
                clearDrawingCanvas();
            }

        }

        onMapPanningStarted: {
            mapWasPanned = true;
            multipathDrawingMouseArea.cursorShape = Qt.ClosedHandCursor;
        }

        onMapPanningFinished: {
            allowMapToPan = false;
            mapWasPanned = true;
            multipathDrawingMouseArea.cursorShape = Qt.CrossCursor;
        }

        onPressAndHold: {
        }

        onReleased: {
            mouse.accepted = true;

            if (!endDrawingByDoubleClick) {
                var coordinate = screenPositionToLatLong(mouse);
                pathCoordinates.push({"screen": {"x": mouse.x, "y": mouse.y}, "coordinate": {"longitude": coordinate.longitude, "latitude": coordinate.latitude }});
                if (pathCoordinates.length > 1) {
                    addMultipathToMap(Singletons.Constants.kDrawDraft);
                }
            }
            else {
                pathCoordinates.pop();
                if (mapViewPlus.pathCoordinates.length <= 1) {
                    clearDrawingCanvas();
                    previewMap.map.clearMapItems();
                    drawingFinished();
                }
                else {
                    addMultipathToMap(Singletons.Constants.kDrawFinal);
                }
                endDrawingByDoubleClick = false;
            }
        }

        onPositionChanged: { 
            var lastKnownPosition;

            if (!mapWasPanned) {
                if (pathCoordinates.length > 0) {
                    drawHelperLine(mouse.x, mouse.y);
                }
                if (mouse !== null) {
                    var coordinate = screenPositionToLatLong(mouse);
                    mapViewPlus.positionChanged({"screen": {"x": mouse.x, "y": mouse.y}, "coordinate": {"longitude": coordinate.longitude, "latitude": coordinate.latitude }});
                    lastKnownPosition = {"screen": {"x": mouse.x, "y": mouse.y}, "coordinate": {"longitude": coordinate.longitude, "latitude": coordinate.latitude }};
                }
            }
            else {
                mapWasPanned = false;
            }
        }

        onDoubleClicked: {
            mouse.accepted = false;
            if (drawMultipath){
                endDrawingByDoubleClick = true;
            }
        }

        Keys.onPressed: {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                addMultipathToMap(Singletons.Constants.kDrawFinal);
            }
            if (event.key === Qt.Key_Delete || event.key === Qt.Key_Backspace) {
                mapViewPlus.pathCoordinates.pop();
                if (mapViewPlus.pathCoordinates.length === 0) {
                    clearDrawingCanvas();
                    previewMap.map.clearMapItems();
                }
                else {
                    addMultipathToMap(Singletons.Constants.kDrawDraft);
                    if(lastKnownPosition !== null){
                        drawHelperLine(lastKnownPosition.screen.x, lastKnownPosition.screen.y);
                    }
                }
            }
            if (event.key === Qt.Key_Shift) {
                multipathDrawingMouseArea.cursorShape = Qt.OpenHandCursor;
            }
        }

        Keys.onReleased: {
            if (event.key === Qt.Key_Shift) {
                multipathDrawingMouseArea.cursorShape = Qt.CrossCursor;
            }
        }

        function drawHelperLine(inX, inY){
            var lastCollectedPath = pathCoordinates[pathCoordinates.length-1];
            var lcpAsPoint = latLongToScreenPosition(lastCollectedPath.coordinate);
            clearDrawingCanvas();
            mapDrawCanvas.getContext('2d').beginPath();
            mapDrawCanvas.getContext('2d').lineWidth = "1";
            mapDrawCanvas.getContext('2d').strokeStyle = drawnExtentOutlineColor;
            mapDrawCanvas.getContext('2d').moveTo(lcpAsPoint.x, lcpAsPoint.y);
            mapDrawCanvas.getContext('2d').lineTo(inX,inY);
            mapDrawCanvas.getContext('2d').stroke();
        }
    }

    //--------------------------------------------------------------------------

    MouseArea {
        id: envelopeDrawingMouseArea
        enabled: (drawing && drawEnvelope) ? true : false
        visible: (drawing && drawEnvelope) ? true : false
        focus: (drawing && drawEnvelope) ? true : false
        clip: true
        anchors.fill: parent
        z: previewMap.z + 2
        cursorShape: (drawing) ? Qt.CrossCursor : Qt.ArrowCursor
        propagateComposedEvents: true

        onPressed: {
            mouse.accepted = true;
            drawingStartCoord.x = mouse.x;
            drawingStartCoord.y = mouse.y;
        }

        onReleased: {
            mouse.accepted = true;
            drawingEndCoord.x = mouse.x;
            drawingEndCoord.y = mouse.y;
            addEnvelopeToMap();
        }

        onPositionChanged: {
            // This most likely needs to be throttled to every 47 milliseconds (24 frames per second)
            mouse.accepted = true;
            var xDif = mouse.x - drawingStartCoord.x;
            var yDif = mouse.y - drawingStartCoord.y;
            mapDrawCanvas.requestPaint();
            mapDrawCanvas.getContext("2d").clearRect(0, 0, mapDrawCanvas.width,mapDrawCanvas.height);
            mapDrawCanvas.getContext("2d").beginPath();
            mapDrawCanvas.getContext("2d").lineWidth = "2";
            mapDrawCanvas.getContext("2d").strokeStyle = drawnExtentOutlineColor;
            mapDrawCanvas.getContext("2d").rect(drawingStartCoord.x,drawingStartCoord.y,xDif, yDif);
            mapDrawCanvas.getContext("2d").stroke();
            if (mouse !== null) {
                var coordinate = screenPositionToLatLong(mouse);
                mapViewPlus.positionChanged({"screen": {"x": mouse.x, "y": mouse.y}, "coordinate": {"longitude": coordinate.longitude, "latitude": coordinate.latitude }})
            }
        }

        onDoubleClicked: {
            mouse.accepted = false;
        }
    }

    //--------------------------------------------------------------------------

    Canvas {
        id: mapDrawCanvas
        anchors.fill: parent
        clip: true
        width: parent.width
        height: parent.height
        visible: (drawing) ? true : false
        z: previewMap.z + 1
    }

    //--------------------------------------------------------------------------

    MouseArea {
        id: mapEventCollectorOther
        clip: true
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        preventStealing: true
        z: previewMap.z - 1
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: {
            if (mouse.button === Qt.LeftButton) {
                mouse.accepted = false;
            }
            if (!drawing) {
               previewMap.focus = true;
            }
        }

        onEntered: {
            cursorIsOffMap = false;
        }

        onPositionChanged: {
            if (mouse !== null) {
                var coordinate = screenPositionToLatLong(mouse);
                mapViewPlus.positionChanged({"screen": {"x": mouse.x, "y": mouse.y}, "coordinate": {"longitude": coordinate.longitude, "latitude": coordinate.latitude }})
            }
        }

        onExited: {
            cursorIsOffMap = true;
            mapViewPlus.positionChanged({"x":-1, "y":-1});
        }

        onDoubleClicked: {
            mouse.accepted = true;
            if (mouse !== null && mouse.button === Qt.RightButton) {
                var coordinate = screenPositionToLatLong(mouse);
                mapViewPlus.map.center = QtPositioning.coordinate(coordinate.latitude, coordinate.longitude);
                if (mouse.modifiers === Qt.ControlModifier) {
                    mapZoomOut.clicked();
                }
                else {
                    mapZoomIn.clicked();
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    MapView {
        id: previewMap
        portal: mapViewPlusPortal
        anchors.fill: parent
        defaultCenter: mapDefaultCenter
        defaultZoomLevel: mapDefaultZoomLevel
        mapService: mapTileService
        useToken: mapTileServiceUsesToken
        z: 50000
        focus: !drawing

        onZoomLevelChanged: {
            mapViewPlus.zoomLevelChanged(level);
        }

        onMapItemsCleared: {
            mapViewPlus.drawingCleared();
        }

        onMapServiceChanged: {
            resetProperties();
        }

        onMapLoadedChanged: {
            if (mapLoaded){
                if (previewMap.lastKnownCenter !== null){
                    previewMap.map.center = previewMap.lastKnownCenter;
                }
                if (previewMap.lastKnownZoomLevel > -1) {
                    previewMap.map.zoomLevel = previewMap.lastKnownZoomLevel;
                }
                basemapLoaded();
            }
        }

        onMapPanningFinished: {
            if (multipathDrawingMouseArea.enabled) {
                multipathDrawingMouseArea.mapPanningFinished();
            }
        }

        onMapPanningStarted: {
            if (multipathDrawingMouseArea.enabled) {
                multipathDrawingMouseArea.mapPanningStarted();
            }
        }

        Keys.onPressed: {
            if ( (event.key === Qt.Key_V) && (event.modifiers === Qt.ControlModifier) ) {
                console.log("paste")
                if (AppFramework.clipboard.dataAvailable) {
                    try {
                        var json = JSON.parse(AppFramework.clipboard.text)
                        geoJsonHelper.parseGeometry(json);
                    }
                    catch(e) {
                        console.log("not json")
                    }
                }
            }
        }
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    MapRectangle {
        id: drawnExtent
        color: drawingExtentFillColor
        border.width: sf(2)
        border.color: drawnExtentOutlineColor
    }

    //--------------------------------------------------------------------------

    MapPolyline{
        id: drawnPolyline
        line.width: sf(3)
        line.color: drawnExtentOutlineColor
    }

    //--------------------------------------------------------------------------

    MapPolygon{
        id: drawnPolygon
        color: drawingExtentFillColor
        border.width: sf(2)
        border.color: drawnExtentOutlineColor
    }

    //--------------------------------------------------------------------------

    MapQuickItem {
        id: clearExtentMapItem
        visible: false
        enabled: false

        sourceItem: Item {
            width: sf(30)
            height: sf(62)

            ColumnLayout {
                anchors.fill: parent
                spacing: sf(2)

                Button {
                    id: saveBookmarkBtn
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    ToolTip.text: Singletons.Strings.saveAsBookmark
                    ToolTip.visible: hovered

                    background: Rectangle {
                        anchors.fill: parent
                        color: "#fff"
                        radius: 0

                        IconFont {
                            anchors.centerIn: parent
                            color: app.info.properties.mainButtonBorderColor
                            icon: _icons.add_bookmark
                        }
                    }
                    onClicked: {
                        addBookmarkDialog.x = clearExtentMapItem.x
                        addBookmarkDialog.y = clearExtentMapItem.y
                        addBookmarkDialog.open();
                    }
                }

                Button {
                    id: clearExtentBtn
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    ToolTip.text: Singletons.Strings.deleteExtent
                    ToolTip.visible: hovered

                    background: Rectangle {
                        anchors.fill: parent
                        color: "#fff"
                        radius: 0

                        Image {
                            source: "images/clear_extent.png"
                            fillMode: Image.PreserveAspectFit
                            width: parent.width - sf(4)
                            anchors.centerIn: parent
                        }
                    }
                    onClicked: {
                        clearExtentMapItem.visible = false;
                        clearExtentMapItem.enabled = false;
                        mapViewPlus.clearMap();
                    }
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    MapQuickItem {
        id: closePolygonMapItem
        visible: false
        enabled: false
        sourceItem: Item {
            width: sf(10)
            height: sf(10)
            Rectangle {
               anchors.fill: parent
               radius: sf(5)
               color: "gold"
               border.color: "blue"
               border.width: sf(2)
            }
        }
    }

    //--------------------------------------------------------------------------

    GeoJsonHelper{
        id: geoJsonHelper

        onSuccess: {
            drawingStarted();
            pathCoordinates = geometry.coordinatesForQML;
            if (geometry.type !== "") {
                if (geometry.type === "esriGeometryPolygon") {
                    geometryType = Singletons.Constants.kPolygon;
                    addPolygonToMap(Singletons.Constants.kDrawFinal);
                }

                if (geometry.type === "esriGeometryPolyline") {
                    geometryType = Singletons.Constants.kMultipath;
                    addMultipathToMap(Singletons.Constants.kDrawFinal);
                }
            }

            mapViewPlus.map.fitViewportToMapItems();
        }

        onError: {
            drawingError(message);
        }
    }

    //--------------------------------------------------------------------------

    Dialog {
        id: addBookmarkDialog
        modal: true
        width: sf(200)
        height: sf(130)

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: sf(30)
                RowLayout {
                    anchors.fill: parent
                    spacing: sf(8)
                    Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: height
                        IconFont {
                            anchors.centerIn: parent
                            icon: _icons.add_bookmark
                            color: Singletons.Colors.mainButtonBackgroundColor
                        }
                    }
                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Text {
                            anchors.fill: parent
                            text: qsTr("Enter a title")
                            verticalAlignment: Text.AlignVCenter
                            font.pointSize: Singletons.Config.baseFontSizePoint
                            font.family: notoRegular
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: sf(30)

                Controls.StyledTextField {
                    id: bookmarkTitle
                    anchors.fill: parent
                    placeholderText: qsTr("Enter a title")
                }
            }

            Item {
                Layout.fillHeight: true
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: sf(1)
                Layout.bottomMargin: sf(8)
                color: Singletons.Colors.mediumGray
            }

            Item {
                Layout.preferredHeight: sf(30)
                Layout.fillWidth: true
                RowLayout {
                    anchors.fill: parent
                    spacing: sf(8)

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Button {
                            id: cancelBm
                            anchors.fill: parent

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
                                font.pointSize: Singletons.Config.smallFontSizePoint
                                font.family: notoRegular
                            }

                            onClicked: {
                                addBookmarkDialog.reject();
                            }
                        }
                    }
                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Button {
                            id: addBM
                            anchors.fill: parent
                            enabled: bookmarkTitle.text > ""

                            background: Rectangle {
                                anchors.fill: parent
                                color: Singletons.Config.buttonStates(parent)
                                radius: app.info.properties.mainButtonRadius
                                border.width: parent.enabled ? app.info.properties.mainButtonBorderWidth : 0
                                border.color: "#fff"
                            }

                            Text {
                                color: app.info.properties.mainButtonFontColor
                                anchors.centerIn: parent
                                textFormat: Text.RichText
                                text: Singletons.Strings.create
                                font.pointSize: Singletons.Config.smallFontSizePoint
                                font.family: notoRegular
                            }

                            onClicked: {
                                addBookmarkDialog.accept();
                            }
                        }
                    }
                }
            }
        }

        onAccepted: {
            if (bookmarkTitle.text > "") {
                var _tpkGeo = JSON.stringify(getLastDrawing());
                var _geoJSON = JSON.stringify(geoJsonHelper.toGeoJSON(_tpkGeo));

                var sql = "INSERT into 'bookmarks' ";
                sql += "(name, tpk_app_geometry, geojson, user) ";
                sql += "VALUES(:title, :tpkGeo, :geoJson, :user)";

                var params = {
                    "title": bookmarkTitle.text,
                    "tpkGeo": _tpkGeo,
                    "geoJson": _geoJSON,
                    "user": portal.user.email
                }
                appDatabase.write(sql, params);
                bookmarkTitle.clear();
                addBookmarkDialog.close();
                saveBookmarkBtn.enabled = false;
                _loadBookmarks();
            }
        }

        onRejected: {
            bookmarkTitle.clear();
            addBookmarkDialog.close();
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: bookmarkDelegate

        Item {
            id: innerDelegate
            width: parent.width
            height: sf(35)

            property var geoInfo: JSON.parse(tpk_app_geometry)

            RowLayout {
                anchors.fill: parent
                anchors.bottomMargin: sf(5)
                spacing: sf(3)

                Button {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    ToolTip.text: Singletons.Strings.addBookmarkToMap
                    ToolTip.visible: hovered
                    background: Rectangle {
                        anchors.fill: parent
                        color: Singletons.Config.buttonStates(parent)
                        radius: sf(4)
                        border.width: parent.enabled ? app.info.properties.mainButtonBorderWidth : 0
                        border.color: app.info.properties.mainButtonBorderColor
                    }
                    RowLayout {
                        anchors.fill: parent
                        spacing: 0
                        Item {
                            Layout.fillHeight: true
                            Layout.preferredWidth: height
                            IconFont {
                                anchors.centerIn: parent
                                icon: innerDelegate.geoInfo.type === Singletons.Constants.kMultipath ? _icons.draw_path : _icons.draw_polygon
                                iconSizeMultiplier: .8
                                color: app.info.properties.mainButtonFontColor
                            }
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Text {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                text: name
                                font.family: notoRegular
                                font.pointSize: Singletons.Config.smallFontSizePoint
                                elide: Text.ElideRight
                                color: app.info.properties.mainButtonFontColor
                            }
                        }
                    }

                    onClicked: {
                        //var inBookmark = JSON.parse(tpk_app_geometry);
                        redraw(innerDelegate.geoInfo);
                        bookmarksPopup.close();
                    }
                }
                Button {
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    ToolTip.text: qsTr("Download as geojson")
                    ToolTip.visible: hovered
                    background: Rectangle {
                        anchors.fill: parent
                        color: Singletons.Config.buttonStates(parent, "clear")
                        radius: sf(4)
                        border.width: parent.enabled ? app.info.properties.mainButtonBorderWidth : 0
                        border.color: app.info.properties.mainButtonBorderColor
                        }

                    IconFont {
                        anchors.centerIn: parent
                        icon: _icons.download
                        iconSizeMultiplier: .8
                        color: parent.hovered ? app.info.properties.mainButtonBorderColor : app.info.properties.mainButtonBackgroundColor
                    }

                    onClicked: {
                        geoJsonHelper.saveGeojsonToFile(JSON.parse(geojson), name);
                    }
                }
                Button {
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    ToolTip.text: Singletons.Strings.deleteBookmark
                    ToolTip.visible: hovered
                    background: Rectangle {
                        anchors.fill: parent
                        color: Singletons.Config.buttonStates(parent, "clear")
                        radius: sf(4)
                        border.width: parent.enabled ? app.info.properties.mainButtonBorderWidth : 0
                        border.color: app.info.properties.mainButtonBorderColor
                        }

                    IconFont {
                        anchors.centerIn: parent
                        icon: _icons.trash_bin
                        iconSizeMultiplier: .8
                        color: parent.hovered ? app.info.properties.mainButtonBorderColor : app.info.properties.mainButtonBackgroundColor
                    }

                    onClicked: {
                        var sql = "DELETE from 'bookmarks' WHERE OBJECTID = %1".arg(OBJECTID);
                        appDatabase.write(sql);
                        _loadBookmarks();
                    }
                }
            }
        }
    }

    // METHODS /////////////////////////////////////////////////////////////////

    function getCurrentGeometry(){
        console.log("----------------getCurrentGeometry():", geometryType);
        var g;
        if (drawMultipath) {
            g = getMutlipathGeometry();
        }
        else if (drawEnvelope) {
            g = getPolygonGeometry();
        }
        else if (drawPolygon) {
            g = getPolygonGeometry();
        }
        else {
            g = null;
        }

        return g;

    }

    //--------------------------------------------------------------------------

    function getEnvelopeGeometry() {

        var rect;

        if (userDrawnExtent === true) {
            rect = drawnExtent
        }
        else {
            rect = QtPositioning.shapeToRectangle(previewMap.map.visibleRegion)
        }

        var xmin = rect.topLeft.longitude
        var ymax = rect.topLeft.latitude
        var xmax = rect.bottomRight.longitude
        var ymin = rect.bottomRight.latitude

        var envelope = {
            xmin: xmin,
            ymin: ymin,
            xmax: xmax,
            ymax: ymax,
            spatialReference: {
                wkid: mapSpatialReference // 4326
            }
        }

        var envelopeGeometry = {
            "geometryType": "esriGeometryEnvelope",
            "geometries" : envelope
        }

        return envelopeGeometry;
    }

    //--------------------------------------------------------------------------

    function getPolygonGeometry(){

        var esriPolygonObject = {
            "geometryType": "esriGeometryPolygon",
            "geometries" : [{
                "rings":[[]],
                "spatialReference": {
                    "wkid": mapSpatialReference
                }
            }]
        };

        for (var i = 0; i < pathCoordinates.length; i++) {
            esriPolygonObject.geometries[0].rings[0].push([pathCoordinates[i].coordinate.longitude, pathCoordinates[i].coordinate.latitude]);
        }

        return esriPolygonObject;

    }

    //--------------------------------------------------------------------------

    function getMutlipathGeometry(){

        // This looks convoluted because esri polyline json is composed of multiple nested arrays

        var esriPolyLineObject = {
                "geometryType": "esriGeometryPolyline",
                "geometries" : [{
                    "paths":[[]],
                    "spatialReference": {
                        "wkid": mapSpatialReference
                    }
                }],

            };

        for (var i = 0; i < pathCoordinates.length; i++) {
            esriPolyLineObject.geometries[0].paths[0].push([pathCoordinates[i].coordinate.longitude, pathCoordinates[i].coordinate.latitude]);
        }

        return esriPolyLineObject;
    }

    //--------------------------------------------------------------------------

    function screenPositionToLatLong(screenPoint) {
        return previewMap.map.toCoordinate(Qt.point(parseInt(screenPoint.x,10), parseInt(screenPoint.y, 10)));
    }
    //--------------------------------------------------------------------------

    function latLongToScreenPosition(coord) {
        return previewMap.map.fromCoordinate(QtPositioning.coordinate(coord.latitude, coord.longitude), false);
    }

    //--------------------------------------------------------------------------

    function clearMap() {
        previewMap.map.clearMapItems();
    }

    //--------------------------------------------------------------------------

    function addEnvelopeToMap() {

        _fixDrawnCoordinates();

        userDrawnExtent = true;

        // Convert coords
        topLeft = screenPositionToLatLong(drawingStartCoord);
        bottomRight = screenPositionToLatLong(drawingEndCoord);

        var path = [];
        path.push({"coordinate": {"longitude": topLeft.longitude, "latitude": topLeft.latitude}});
        path.push({"coordinate": {"longitude": bottomRight.longitude, "latitude": topLeft.latitude}});
        path.push({"coordinate": {"longitude": bottomRight.longitude, "latitude": bottomRight.latitude}});
        path.push({"coordinate": {"longitude": topLeft.longitude, "latitude": bottomRight.latitude}});
        path.push({"coordinate": {"longitude": topLeft.longitude, "latitude": topLeft.latitude}});

        pathCoordinates = path;
        addPolygonToMap(Singletons.Constants.kDrawFinal)
    }

    //--------------------------------------------------------------------------

    function addMultipathToMap(typeOfPath){

        clearMap();

        var path = [];
        for (var i = 0; i < pathCoordinates.length; i++) {
            path.push(pathCoordinates[i]['coordinate']);
        }

        drawnPolyline.path = path;

        previewMap.map.addMapItem(drawnPolyline);

        if (drawPolygon && typeOfPath === Singletons.Constants.kDrawDraft) {
            mapViewPlus.map.addMapItem(closePolygonMapItem);
            closePolygonMapItem.anchorPoint = Qt.point(closePolygonMapItem.sourceItem.width/2,closePolygonMapItem.sourceItem.height/2)
            closePolygonMapItem.coordinate = QtPositioning.coordinate(path[0].latitude, path[0].longitude);
            closePolygonMapItem.visible = true;
            closePolygonMapItem.enabled = true;
        }

        if (typeOfPath === Singletons.Constants.kDrawFinal) {
            _updateDrawingHistory("add",
                                  {
                                      "type": Singletons.Constants.kMultipath,
                                      "geometry": pathCoordinates
                                  });
            userDrawnExtent = true;
            clearDrawingCanvas();

            previewMap.map.addMapItem(clearExtentMapItem)
            clearExtentMapItem.anchorPoint = Qt.point(clearExtentMapItem.sourceItem.width, clearExtentMapItem.sourceItem.height);
            clearExtentMapItem.coordinate = QtPositioning.coordinate(path[0].latitude, path[0].longitude);
            clearExtentMapItem.visible = true;
            clearExtentMapItem.enabled = true;
            saveBookmarkBtn.enabled = true;

            drawingFinished();
        }
    }

    //--------------------------------------------------------------------------

    function addPolygonToMap(typeOfPath){

        clearMap();

        var path = [];

        for (var i = 0; i < pathCoordinates.length; i++) {
            path.push(pathCoordinates[i]['coordinate']);
        }

        drawnPolygon.path = path;

        mapViewPlus.map.addMapItem(drawnPolygon);

        if (typeOfPath === Singletons.Constants.kDrawFinal) {
            _updateDrawingHistory("add",
                                  {
                                      "type": Singletons.Constants.kPolygon,
                                      "geometry": pathCoordinates
                                  });
            userDrawnExtent = true;
            clearDrawingCanvas();

            mapViewPlus.map.addMapItem(clearExtentMapItem);
            clearExtentMapItem.anchorPoint = Qt.point(clearExtentMapItem.sourceItem.width, clearExtentMapItem.sourceItem.height);
            clearExtentMapItem.coordinate = QtPositioning.coordinate(path[0].latitude, path[0].longitude);
            clearExtentMapItem.visible = true;
            clearExtentMapItem.enabled = true;
            saveBookmarkBtn.enabled = true;

            closePolygonMapItem.visible = false;
            closePolygonMapItem.enabled = false;

            drawingFinished();
        }
    }

    //--------------------------------------------------------------------------

    function _fixDrawnCoordinates() {

        var mapMinX = mapDrawCanvas.x
        var mapMinY = mapDrawCanvas.y
        var mapMaxX = mapDrawCanvas.x + mapDrawCanvas.width
        var mapMaxY = mapDrawCanvas.y + mapDrawCanvas.height

        var newStartX, newStartY, newEndX, newEndY

        var xDif = drawingEndCoord.x - drawingStartCoord.x
        var yDif = drawingEndCoord.y - drawingStartCoord.y
        var xPoz = (xDif > 0) ? true : false
        var yPoz = (yDif > 0) ? true : false

        if (xPoz === true && yPoz === true) {
            console.log('drawing from top left to bottom right, coords are good')
        }
        if (xPoz === true && yPoz === false) {
            // Drawing from bottom left to top right > swap y values
            newStartY = drawingEndCoord.y
            newEndY = drawingStartCoord.y
            drawingStartCoord.y = newStartY
            drawingEndCoord.y = newEndY
        }
        if (xPoz === false && yPoz === true) {
            // Drawing top right to bottom left > swap x values
            newStartX = drawingEndCoord.x
            newEndX = drawingStartCoord.x
            drawingStartCoord.x = newStartX
            drawingEndCoord.x = newEndX
        }
        if (xPoz === false && yPoz === false) {
            // drawing bottom right to top left > swap start and end values for each other
            newStartX = drawingEndCoord.x
            newStartY = drawingEndCoord.y
            newEndX = drawingStartCoord.x
            newEndY = drawingStartCoord.y
            drawingStartCoord.x = newStartX
            drawingStartCoord.y = newStartY
            drawingEndCoord.x = newEndX
            drawingEndCoord.y = newEndY
        }

        // Fix coords if they go beyond map boundaries > snap back to min and max.
        if (drawingStartCoord.x < mapMinX) {
            drawingStartCoord.x = mapMinX
        }
        if (drawingStartCoord.y < mapMinY) {
            drawingStartCoord.y = mapMinY
        }
        if (drawingEndCoord.x > mapMaxX) {
            drawingEndCoord.x = mapMaxX
        }
        if (drawingEndCoord.y > mapMaxY) {
            drawingEndCoord.y = mapMaxY
        }
    }

    //--------------------------------------------------------------------------

    function resetProperties() {
        pathCoordinates = [];
        drawingStartCoord.x = null;
        drawingStartCoord.y = null;
        drawingEndCoord.x = null;
        drawingEndCoord.y = null;
        topLeft = null;
        bottomRight = null;
        userDrawnExtent = false;
        geometryType = "";
    }

    //--------------------------------------------------------------------------

    function clearDrawingCanvas(){
        mapDrawCanvas.requestPaint();
        mapDrawCanvas.getContext("2d").clearRect(0,0,mapDrawCanvas.width, mapDrawCanvas.height);
    }

    //--------------------------------------------------------------------------

    function isJson(item){
        var jsonExtension = ".json";
        var geoJsonExtension = ".geojson";
        if ( (item.indexOf(jsonExtension, item.lastIndexOf('/') + 1)) > -1 || (item.indexOf(geoJsonExtension, item.lastIndexOf('/') + 1)) > -1  ) {
            console.log('is json');
            return true;
        }
        else {
            console.log('is not json');
            return false;
        }
    }

    //--------------------------------------------------------------------------

    function getLastDrawing(){
        if (historyAvailable){
            return drawingHistory[drawingHistory.length -1];
        }
        else {
            return "";
        }
    }

    //--------------------------------------------------------------------------

    function _updateDrawingHistory(op, geo){

        if (op === "add") {
            drawingHistory.push(geo);
        }
        else if (op === "delete") {
            // todo
        }
        else if (op === "clear") {
            drawingHistory = [];
        }
        else {
        }

        if (drawingHistory.length > 0){
            historyAvailable = true;
        }
        else {
            historyAvailable = false;
        }
    }

    //--------------------------------------------------------------------------

    function _loadBookmarks(){
        userBookmarks = appDatabase.read("SELECT * FROM 'bookmarks' WHERE user IS '%1'".arg(portal.user.email));
    }

    // END /////////////////////////////////////////////////////////////////////
}
