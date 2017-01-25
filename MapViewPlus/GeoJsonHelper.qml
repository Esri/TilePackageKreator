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

import QtQuick 2.0
import ArcGIS.AppFramework 1.0
import '../Geometry'

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

    signal success(var geometry)
    signal error(string message)

    // METHODS /////////////////////////////////////////////////////////////////

    function parseGeometryFromFile(filepath){

        if(geoJsonFileFolder.fileExists(filepath)){
            try{
                var json = geoJsonFileFolder.readJsonFile(filepath)
                _normalize(json);
            }
            catch(error){
                error("There was an error reading the JSON file.");
            }
        }
        else{
            error("JSON file doesn't exist");
        }
    }

    //--------------------------------------------------------------------------

    function parseGeometry(json){
        _normalize(json);
    }

    //--------------------------------------------------------------------------

    function _normalize(json){

        var features;
        var isWebMercator = false;

        if(json.hasOwnProperty("features")){

            if(json.features.length > 0){
                features = json.features[0];
            }

            // Esri geojson has crs property -----------------------------------

            if(json.hasOwnProperty("crs")){
                var sr = json.crs.properties.name;
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

            if(json.hasOwnProperty("spatialReference")){
                if(json.spatialReference.wkid === 102100 || json.spatialReference.wkid === 3857 || json.spatialReference.latestWkid === 3857){
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

            if(json.hasOwnProperty("geometryType")){
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

    // COMPONENTS //////////////////////////////////////////////////////////////

    FileFolder {
        id: geoJsonFileFolder
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
