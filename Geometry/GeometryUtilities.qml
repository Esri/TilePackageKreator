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

    id: geomUtilities

    // METHODS /////////////////////////////////////////////////////////////////

    function getExtent(coordinates /* [ [longitude in decimal degrees, latitude in decimal degrees] ] */){

       var extent = {
                    "xmin": 0,
                    "ymin": 0,
                    "xmax": 0,
                    "ymax": 0,
                    "center": {
                        "longitude": 0,
                        "latitude": 0
                        }
                    }

        // x, longitude --------------------------------------------------------

        coordinates.sort(function(a, b) {
                        return a[0] - b[0];
                    });

        var xmin = coordinates[0][0];
        var xmax = coordinates[coordinates.length - 1][0];

        if(xmin < 0 && xmax < 0){
            xmin = coordinates[coordinates.length - 1][0];
            xmax = coordinates[0][0];
        }

        extent.xmin = xmin;
        extent.xmax = xmax;

        // y, latitude ---------------------------------------------------------

        coordinates.sort(function(a, b) {
                        return a[1] - b[1];
                    });

        var ymin = coordinates[0][1];
        var ymax = coordinates[coordinates.length - 1][1];

        if (ymin < 0 && ymax < 0) {
            ymin = coordinates[coordinates.length - 1][1];
            ymax = coordinates[0][1];
        }

        extent.ymin = ymin;
        extent.ymax = ymax;

        extent.center = getCenter(extent);

        return extent;

    }

    //--------------------------------------------------------------------------

    function getCenter(coordinates /* {xmin, ymin, xmax, ymax} */){
        var xCenter = (coordinates.xmin + coordinates.xmax) / 2.0;
        var yCenter = (coordinates.ymin + coordinates.ymax) / 2.0;
        var center = {
            "longitude": xCenter,
            "latitude": yCenter
        };

        return center;
    }

    // END /////////////////////////////////////////////////////////////////////
}
