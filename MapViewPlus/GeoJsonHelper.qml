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
        "coordinatesForQML": []
    }

    property int inSR
    property int outSR

    signal success(var geometry)
    signal error(string message)

    // METHODS /////////////////////////////////////////////////////////////////

    function parseGeometry(filepath, outSR /* only 4326 or 3857 are valid */){

        if(geoJsonFileFolder.fileExists(filepath)){
            try{
                var json = geoJsonFileFolder.readJsonFile(filepath)
                if(outSR !== null && outSR !== undefined && outSR !== ""){

                }
                _normalize(json);
            }
            catch(error){
                error(error.toString());
            }
            finally{
                success(returnGeometry);
            }

        }
        else{
            error("file doesn't exist");
        }

    }

    //--------------------------------------------------------------------------

    function _normalize(json){

        var features;
        var isWebMercator = false;

        if(json.hasOwnProperty("features")){

            if(json.features.length > 0){
                features = json.features[0];
            }

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
                }

                // "EPSG:4326" or "EPSG:3857"
            }

            if(json.hasOwnProperty("spatialReference")){
                if(json.spatialReference.wkid === 102100 || json.spatialReference.wkid === 3857 || json.spatialReference.latestWkid === 3857){
                    //returnGeometry.spatialReference = 3857;
                    isWebMercator = true;
                }
            }

            if(features.hasOwnProperty("geometry")){

                if(features.geometry.hasOwnProperty("coordinates")){
                    returnGeometry.coordinates = features.geometry.coordinates;
                }
                else if(features.geometry.hasOwnProperty("paths")){
                    if(features.geometry.paths.length > 0){
                        returnGeometry.coordinates = features.geometry.paths[0];
                    }
                }
                else{
                    returnGeometry.coordinates = [];
                }

                if(isWebMercator){
                    var newCoords = [];
                    for(var i = 0; i < returnGeometry.coordinates.length; i++){
                       newCoords.push(converter.xyToLngLat(returnGeometry.coordinates[i]));
                    }

                    returnGeometry.coordinates = newCoords;
                }


                returnGeometry.coordinatesForQML = _prepareGeometryForQMLMapPolyline(returnGeometry.coordinates)


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


            }

        }
        else{
            error("Missing Feature Geometry");
        }

    }

    //--------------------------------------------------------------------------

    function _prepareGeometryForQMLMapPolyline(coords){

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

    // END /////////////////////////////////////////////////////////////////////
}
