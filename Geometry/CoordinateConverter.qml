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

QtObject {

    id: coordinateConverter

    // PROPERTIES //////////////////////////////////////////////////////////////

    readonly property double radiansPerDegree: Math.PI / 180
    readonly property double degreesPerRadian: 180 / Math.PI
    readonly property double earthRadius: 6378137.0

    // METHODS /////////////////////////////////////////////////////////////////

    function lngLatToXY(point){

        var inX = parseFloat(point.longitude);
        var inY = parseFloat(point.latitude);

        var newX =  earthRadius * (inX * radiansPerDegree);
        var newY = (earthRadius / 2) * Math.log( (1.0 + Math.sin(inY * radiansPerDegree))  / (1.0 - Math.sin(inY * radiansPerDegree)) );

        var newCoordinate = { "x": newX, "y": newY };

        return newCoordinate;
    }

    //--------------------------------------------------------------------------

    function xyToLngLat(point){

        var inX = parseFloat(point.x);
        var inY = parseFloat(point.y);

        var latRadians = ( 2.0 * Math.atan(Math.exp(inY / earthRadius)) ) - (Math.PI / 2.0);
        var lonRadians = inX / earthRadius;

        var lat = latRadians * degreesPerRadian;
        var lon = lonRadians * degreesPerRadian;

        lon = _fixLongitude(lon);
        lat = _fixLatitude(lat);

        var newCoordinate = { "longitude": lon, "latitude": lat };

        return newCoordinate;

    }

    //--------------------------------------------------------------------------

    function _fixLongitude(lon){
        if(lon < -180 || lon > 180){
            lon += 180;
            lon = lon % 360.0
            lon = (lon < 0) ? 180 + lon : -180 + lon;
        }
        return lon;
    }

    //--------------------------------------------------------------------------

    function _fixLatitude(lat) {
            if (lat > 90) {
                lat = 90;
            }
            if (lat < -90) {
                lat = -90;
            }
            return lat;
        }


    // END /////////////////////////////////////////////////////////////////////
}
