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

QtObject {

    id: coordinateConverter

    // PROPERTIES //////////////////////////////////////////////////////////////

    readonly property double radiansPerDegree: Math.PI / 180
    readonly property double degreesPerRadian: 180 / Math.PI
    readonly property double earthRadius: 6378137.0

    // METHODS /////////////////////////////////////////////////////////////////

    function lngLatToXY(coordinate /* [longitude in decimal degrees, latitude in decimal degrees] */){

        var inLongitude = parseFloat(coordinate[0]);
        var inLatitude = parseFloat(coordinate[1]);

        var asX =  earthRadius * (inLongitude * radiansPerDegree);
        var asY = (earthRadius / 2) * Math.log( (1.0 + Math.sin(inLatitude * radiansPerDegree))  / (1.0 - Math.sin(inLatitude * radiansPerDegree)) );

        var newCoordinate = [asX, asY];

        return newCoordinate;
    }

    //--------------------------------------------------------------------------

    function xyToLngLat(coordinate /* [x, y]*/){

        var inX = parseFloat(coordinate[0]);
        var inY = parseFloat(coordinate[1]);

        var latRadians = ( 2.0 * Math.atan(Math.exp(inY / earthRadius)) ) - (Math.PI / 2.0);
        var lonRadians = inX / earthRadius;

        var asLatitude = latRadians * degreesPerRadian;
        var asLongitude = lonRadians * degreesPerRadian;

        asLongitude = _fixLongitude(asLongitude);
        asLatitude = _fixLatitude(asLatitude);

        var newCoordinate = [asLongitude, asLatitude];

        return newCoordinate;

    }

    //--------------------------------------------------------------------------

    function _fixLongitude(lon){
        if (lon < -180 || lon > 180) {
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
