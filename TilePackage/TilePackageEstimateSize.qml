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

/*
    NOTE:
    This is a rough size estimation tool.
    It simple takes the number of pixels across and down and divides by tile size.
    This can only be accurate if an extent falls directly on tile boundaries, and doesn't account for when selected extents fall across tile boundaries

*/

import QtQuick 2.15

QtObject {

    id: tpkEstimateSizeComponent

    // PROPERTIES //////////////////////////////////////////////////////////////

    readonly property int tileSize: 256
    readonly property var metersPerPixel: [156412, 78206, 39103, 19551, 9776, 4888, 2444, 1222, 610.984, 305.492, 152.746, 76.373, 38.187, 19.093, 9.547, 4.773, 2.387, 1.193, 0.596, 0.298, 0.149, 0.0746, 0.0373, 0.019]
    readonly property var averageCompressionPercent: [1.0, .86, .79, .76, .72, .7, .68, .67, .525, .33, .21, .13, .08, .06, .05, .033, .0313, .0297, .0283, .0268, .0255, .0242, .023, .0219]
    readonly property double averageBytesPerTile: 280000

    signal calculationComplete(var estimate)

    // METHODS /////////////////////////////////////////////////////////////////

    function calculate(topLeft /* [x,y] as webmercator */, bottomRight /* [x,y] as webmercator */, level /* int */){

        var xMeters = Math.abs(Math.floor(bottomRight[0] - topLeft[0]));

        var yMeters = Math.abs(Math.floor(bottomRight[1] - topLeft[1]));

        var totalTiles = 1;

        if(level > 0){
            for(var a = 1; a < level + 1; a++){

                var xPixels = xMeters  / metersPerPixel[a];
                var yPixels = yMeters / metersPerPixel[a];


                var xTiles = Math.ceil(xPixels / tileSize);
                var yTiles = Math.ceil(yPixels / tileSize);

                var levelTiles = xTiles * yTiles;

                totalTiles += levelTiles;

            }
        }

        var sizeInBytes = (totalTiles * averageBytesPerTile) * averageCompressionPercent[level];

        calculationComplete({"tiles": totalTiles, "bytes": sizeInBytes});
    }

    // -------------------------------------------------------------------------

    function calculateForRange(topLeft /* [x,y] as webmercator */, bottomRight /* [x,y] as webmercator */, bottomLevel /* int */, topLevel /* int */){

        var _topLevel = Math.round(topLevel);
        var _bottomLevel = Math.round(bottomLevel);

        if (_topLevel === metersPerPixel.length + 1){
            _topLevel = metersPerPixel.length;
        }

        if (_bottomLevel < 0){
            _bottomLevel = 0;
        }

        var xMeters = Math.abs(Math.floor(bottomRight[0] - topLeft[0]));
        var yMeters = Math.abs(Math.floor(bottomRight[1] - topLeft[1]));

        var totalTiles = 1;

        if (_topLevel > 0) {

            for (var a = _bottomLevel; a < _topLevel + 1; a++) {

                var xPixels = xMeters / metersPerPixel[a];
                var yPixels = yMeters / metersPerPixel[a];

                var xTiles = Math.ceil(xPixels / tileSize);
                var yTiles = Math.ceil(yPixels / tileSize);

                var levelTiles = xTiles * yTiles;

                totalTiles += levelTiles;
            }
        }

        var compressionLevel = _topLevel !== _bottomLevel ? _topLevel - _bottomLevel : 0;

        var sizeInBytes = (totalTiles * averageBytesPerTile) * averageCompressionPercent[compressionLevel];

        calculationComplete({"tiles": totalTiles, "bytes": sizeInBytes});
    }

    // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////////

    onCalculationComplete: {}

    // END /////////////////////////////////////////////////////////////////////
}
