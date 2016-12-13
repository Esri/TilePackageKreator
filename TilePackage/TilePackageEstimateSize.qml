/*
    NOTE:
    This is a rough size estimation tool.
    It simple takes the number of pixels across and down and divides by tile size.
    This can only be accurate if an extent falls directly on tile boundaries, and doesn't account for when selected extents fall across tile boundaries

*/

import QtQuick 2.0

QtObject {

    id: tpkEstimateSizeComponent

    // PROPERTIES //////////////////////////////////////////////////////////////

    readonly property int tileSize: 256
    readonly property var metersPerPixel: [156412, 78206, 39103, 19551, 9776, 4888, 2444, 1222, 610.984, 305.492, 152.746, 76.373, 38.187, 19.093, 9.547, 4.773, 2.387, 1.193, 0.596, 0.298, 0.149, 0.0746, 0.0373, 0.019]
    readonly property var averageCompressionPercent: [1.0, .86, .79, .76, .72, .7, .68, .67, .525, .33, .21, .13, .08, .06, .05, .033, .0313, .0297, .0283, .0268, .0255, .0242, .023, .0219]
    readonly property double radiansPerDegree: Math.PI / 180
    readonly property double earthRadius: 6378137.0
    readonly property double averageBytesPerTile: 280000

    signal calculationComplete(var estimate)

    // METHODS /////////////////////////////////////////////////////////////////

    function calculate(topLeft /* obj {longitude,latitude}*/, bottomRight /* obj {longitude,latitude} */, level /* int */){

        var topLeftInMeters = latLongToWebMerc(topLeft);

        var bottomRightInMeters = latLongToWebMerc(bottomRight);

        var xMeters = Math.abs(Math.floor(bottomRightInMeters.x - topLeftInMeters.x));

        var yMeters = Math.abs(Math.floor(bottomRightInMeters.y - topLeftInMeters.y));

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

    //--------------------------------------------------------------------------

    function latLongToWebMerc(point){

        var inX = parseFloat(point.longitude);
        var inY = parseFloat(point.latitude);

        var newX =  earthRadius * (inX * radiansPerDegree);
        var newY = (earthRadius / 2) * Math.log( (1.0 + Math.sin(inY * radiansPerDegree))  / (1.0 - Math.sin(inY * radiansPerDegree)) );

        var newPoint = {"x": newX, "y": newY};

        return newPoint;
    }

    // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////////

    onCalculationComplete: {}

    // END /////////////////////////////////////////////////////////////////////
}
