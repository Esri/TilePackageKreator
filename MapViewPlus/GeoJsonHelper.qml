/* Copyright 2017 Esri
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
import QtQuick.Dialogs 1.2
import '../Geometry'
import '../singletons' as Singletons

Item{

    id: geoJsonHelper

    property var returnGeometry:{
        "type": "",
        "spatialReference": 4326, // geojson specification
        "coordinates": [],
        "coordinatesForQML": [],
        "extent": null
    }

    property int inSR
    property int outSR

    property var geojson: null

    property int currentFeature: 0
    property int numberOfFeatures: 0

    signal success(var geometry)
    signal error(string message)

    // METHODS /////////////////////////////////////////////////////////////////

    function setGeoJson(json) {
        geojson = json;
        numberOfFeatures = geojson.features.length;
    }

    function parseGeometryFromFile(filepath){

        if (geoJsonFileFolder.fileExists(filepath)) {
            try {
                var json = geoJsonFileFolder.readJsonFile(filepath)
                setGeoJson(json);
                getFeature(0);
            }
            catch(error) {
                error("There was an error reading the JSON file.");
            }
        }
        else {
            error("JSON file doesn't exist");
        }
    }

    //--------------------------------------------------------------------------

    function getFeature(feature) {
        if (geojson === null) {
            error("No geojson data.");
            return;
        }

        if (feature === undefined || feature < 0 || feature > geojson.features.length){
            feature = 0;
        }
        _normalize(feature);
    }

    //--------------------------------------------------------------------------
    function _normalize(feature){

        if (geojson === null) {
            error("No geojson data.");
            return;
        }

        currentFeature = feature;

        var features;
        var isWebMercator = false;

        if (geojson.hasOwnProperty("features")) {

            if (feature === undefined || feature < 0 || feature > geojson.features.length){
                feature = 0;
            }

            features = geojson.features[feature];

            // Esri geojson has crs property -----------------------------------

            if(geojson.hasOwnProperty("crs")){
                var sr = geojson.crs.properties.name;
                if(sr.indexOf("3857") > -1 || sr.indexOf("102100") > -1){
                    isWebMercator = true;
                    //returnGeometry.spatialReference = 3857;
                }
                else if(sr.indexOf("4326") > -1){
                    returnGeometry.spatialReference = 4326;
                }
                else{
                    returnGeometry.spatialRefernce = null;
                    error("Spatial reference cannot be determined for geojson file.")
                }
            }

            // Esri json has spatialReference property -------------------------

            if(geojson.hasOwnProperty("spatialReference")){
                if(geojson.spatialReference.wkid === 102100 || geojson.spatialReference.wkid === 3857 || geojson.spatialReference.latestWkid === 3857){
                    //returnGeometry.spatialReference = 3857;
                    isWebMercator = true;
                }
            }

            // Normalize type, for convenience normalize to esri types -----

            if(features.geometry.hasOwnProperty("type")){
                if(features.geometry.type === "Polygon"){
                    returnGeometry.type = "esriGeometryPolygon";
                }
                if(features.geometry.type === "LineString"){
                    returnGeometry.type = "esriGeometryPolyline";
                }
            }

            if(geojson.hasOwnProperty("geometryType")){
                returnGeometry.type = json.geometryType;
            }


            if(features.hasOwnProperty("geometry")){

                if(features.geometry.hasOwnProperty("coordinates")){
                    returnGeometry.coordinates = (returnGeometry.type === "esriGeometryPolygon") ? features.geometry.coordinates[0]: features.geometry.coordinates;
                }
                else if(features.geometry.hasOwnProperty("paths")){
                    if(features.geometry.paths.length > 0){
                        returnGeometry.coordinates = features.geometry.paths[0];
                    }
                }
                else if(features.geometry.hasOwnProperty("rings")){
                    if(features.geometry.rings.length > 0){
                        returnGeometry.coordinates = features.geometry.rings[0];
                    }
                }
                else{
                    returnGeometry.coordinates = [];
                }

                // NOTE: Might need to throw an error if coordinate count is way way too large. Needs testing.

                if(returnGeometry.coordinates.length > 0){
                    if(isWebMercator){
                        var newCoordsInLngLat = [];
                        for(var i = 0; i < returnGeometry.coordinates.length; i++){
                           newCoordsInLngLat.push(converter.xyToLngLat(returnGeometry.coordinates[i]));
                        }

                        returnGeometry.coordinates = newCoordsInLngLat;
                    }

                    returnGeometry.coordinatesForQML = _prepareGeometryForQMLMap(returnGeometry.coordinates);

                    success(returnGeometry);
                }
                else{
                    error("JSON is missing geometry");
                }
            }
        }
        else{
            error("JSON is missing 'features' attribute");
        }
    }

    //--------------------------------------------------------------------------

    function _prepareGeometryForQMLMap(coords){

        var qmlGeometry = [];

        for(var i = 0; i < coords.length; i++){

            var set = coords[i];

            var thisPoint = {
                "coordinate": {
                    "longitude": set[0],
                    "latitude": set[1]
                },
                "screen": {
                    "x": null,
                    "y": null
                }
            };

            qmlGeometry.push(thisPoint);
        }

        return qmlGeometry;
    }

    //--------------------------------------------------------------------------

    function toGeoJSON(geometry){
        var g = JSON.parse(geometry);
        var gType;
        var gCoords;

        if (g.hasOwnProperty("type")) {

            if(g.type === Singletons.Constants.kMultipath) {
                gType = "LineString";
                gCoords = [];
                for(var x = 0; x < g.geometry.length; x++){
                    gCoords.push([g.geometry[x].coordinate.longitude, g.geometry[x].coordinate.latitude]);
                }
            }

            if(g.type === Singletons.Constants.kPolygon){
                gType = "Polygon";
                gCoords = [[]];
                for(var y = 0; y < g.geometry.length; y++){
                    gCoords[0].push([g.geometry[y].coordinate.longitude, g.geometry[y].coordinate.latitude]);
                }
            }
        }

        var geoJson = {
            "type": "FeatureCollection",
            "features": [{
                "type": "Feature",
                "properties": {},
                "geometry": {
                    "type": gType,
                    "coordinates": gCoords
                }
            }]
        };

        return geoJson;
    }

    //--------------------------------------------------------------------------

    function saveGeoJsonToFile(geometry,name){
        fileDialog.geoJsonToExport = geometry;
        fileDialog.geoJsonName = name.replace(/[^a-zA-Z0-9]/g,"_").toLocaleLowerCase();
        fileDialog.open();
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    FileFolder {
        id: geoJsonFileFolder
    }

    //--------------------------------------------------------------------------

    FileDialog {
           id: fileDialog
           property var geoJsonToExport: {}
           property string geoJsonName: "data"
           selectFolder: true
           title: Singletons.Strings.saveTo
           onAccepted: {
               geoJsonFileFolder.path = AppFramework.resolvedPath(fileDialog.fileUrl);
               geoJsonFileFolder.writeJsonFile("%1.geojson".arg(geoJsonName), geoJsonToExport);
               fileDialog.close();
           }
        }

    //--------------------------------------------------------------------------

    CoordinateConverter{
        id:converter
    }

    //--------------------------------------------------------------------------

    GeometryUtilities{
        id: geomUtilities
    }

    // END /////////////////////////////////////////////////////////////////////
}
