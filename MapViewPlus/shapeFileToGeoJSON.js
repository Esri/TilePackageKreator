// Based on Esri Shapefile Technical Description
// An Esri White Paper -- July 1998
// https://www.esri.com/library/whitepapers/pdfs/shapefile.pdf

var shpDataArray = null;
var shapeType = null;
var shapeValue = -1;
var shapeFileByteLength = 0;
var partsArray = [];
var pointsArray = [];
var cursor = 0;
var featureCount = 1;

var geoJson = {
    "type": "FeatureCollection",
    "crs": {
        "type" : "name",
        "properties" : {
          "name" : ""
        }
      },
    "bbox": [],
    "shapefile_related": {},
    "features": []
};

WorkerScript.onMessage = function(shapeFile) {

    // shapeFile should be a jsobject with a path attribute and associated file url
    // ex: { "path": "file:///C:/Users/username/Desktop/myshapefiles/rivers.shp", "coordinate_system": "3587" }

    geoJson["crs"]["properties"]["name"] = shapeFile.coordinate_system;

    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            if (xhr.status === 0 || xhr.status === 200){
                shapefileByteArrayToGeoJson(xhr.response);
            }
            else {
                WorkerScript.sendMessage({"error": "There was an error reading the shapefile"});
            }
        }
    };
    xhr.responseType = "arraybuffer";
    xhr.open("GET", shapeFile.path, true);
    xhr.send();
}

function establishSpatialReference(minx, miny, maxx, maxy){
    // the shape file .prj file was other than 3857 or 4326, so attempt
    // to see if it is lat / lon or web mercator type values.

    // its highly unlikely a web mercator projection will fall within
    // the following parameters,

    if (minx > 180 || minx < -180 || maxx > 180 || maxx < -180 || miny > 90 || miny < -90 || maxy > 90 || maxy < -90) {
        return "3857";
    }
    else {
        return "4326";
    }
}

var shapeTypes = [];
shapeTypes[0] = {"esri": "Null Shape", "geojson": null};
shapeTypes[1] = {"esri": "Point", "geojson": "Point"};
shapeTypes[3] = {"esri": "PolyLine", "geojson": "LineString"};
shapeTypes[5] = {"esri": "Polygon", "geojson": "Polygon"};
shapeTypes[8] = {"esri": "MultiPoint", "geojson": "MultiPoint"};
shapeTypes[11] = {"esri": "PointZ", "geojson": null};
shapeTypes[13] = {"esri": "PolyLineZ", "geojson": null};
shapeTypes[15] = {"esri": "PolygonZ", "geojson": null};
shapeTypes[18] = {"esri": "MultiPointZ", "geojson": null};
shapeTypes[21] = {"esri": "PointM", "geojson": null};
shapeTypes[23] = {"esri": "PolyLineM", "geojson": null};
shapeTypes[25] = {"esri": "PolygonM", "geojson": null};
shapeTypes[28] = {"esri": "MultiPointM", "geojson": null};
shapeTypes[31] = {"esri": "MultiPatch", "geojson": null};

var shpHeader = {
    "file_code": {
        "position": 0,
        "type": "int32",
        "bigEndian": true
    },
    "file_length": {
        "position": 24,
        "type": "int32",
        "bigEndian": true
    },
    "version": {
        "position": 28,
        "type": "int32",
        "bigEndian": true
    },
    "shape_type": {
        "position": 32,
        "type": "int32",
        "bigEndian": true
    },
    "xmin": {
        "position": 36,
        "type": "float64",
        "bigEndian": true
    },
    "ymin": {
        "position": 44,
        "type": "float64",
        "bigEndian": true
    },
    "xmax": {
        "position": 52,
        "type": "float64",
        "bigEndian": true
    },
    "ymax": {
        "position": 60,
        "type": "float64",
        "bigEndian": true
    },
    "zmin": {
        "position": 68,
        "type": "float64",
        "bigEndian": true
    },
    "zmax": {
        "position": 76,
        "type": "float64",
        "bigEndian": true
    },
    "mmin": {
        "position": 84,
        "type": "float64",
        "bigEndian": true
    },
    "mmax": {
        "position": 92,
        "type": "float64",
        "bigEndian": true
    }
}

function getShapeType(val){
    return shapeTypes[val];
}

function resetFeatures(){
    shpDataArray = null;
    shapeFileByteLength = 0;
    shapeType = null;
    shapeValue = -1;
    geoJson.features = [];
    cursor = 0;
    partsArray = [];
    pointsArray = [];
    featureCount = 1;
}

function shapefileByteArrayToGeoJson(byteArray) {

    resetFeatures();

    shpDataArray = new DataView(byteArray);

    shapeFileByteLength = shpDataArray.byteLength;

    // A byteLength less than 101 means there is no geometry.-------------------
    if (shapeFileByteLength < 101){
        try {
            throw new Error("This shapefile contains no geometry");
        }
        catch(e) {
            WorkerScript.sendMessage({"error": e});
        }
        finally {
            resetFeatures();
            return;
        }
    }

    shapeValue = shpDataArray.getInt32(shpHeader.shape_type.position, shpHeader.shape_type.bigEndian);
    shapeType = shapeTypes[shapeValue];

    geoJson["shapefile_related"]["byteLength"] = shapeFileByteLength;
    geoJson["shapefile_related"]["shapeType"] = shapeValue;

    // only supporting MultilineString, Polygon --------------------------------
    if (shapeValue !== 3 && shapeValue !== 5) {

        try {
            throw new Error("This tool currently only supports polygons and polylines. Not %1".arg(shapeType.esri));
        }
        catch(e) {
            WorkerScript.sendMessage({"error": e});
        }
        finally {
            resetFeatures();
            return;
        }
    }

    var boundingBoxXMin = shpDataArray.getFloat64(shpHeader.xmin.position, shpHeader.xmin.bigEndian);
    geoJson["bbox"][0] = boundingBoxXMin;

    var boundingBoxYMin = shpDataArray.getFloat64(shpHeader.ymin.position, shpHeader.ymin.bigEndian);
    geoJson["bbox"][1] = boundingBoxYMin;

    var boundingBoxXMax = shpDataArray.getFloat64(shpHeader.xmax.position, shpHeader.xmax.bigEndian);
    geoJson["bbox"][2] = boundingBoxXMax;

    var boundingBoxYMax = shpDataArray.getFloat64(shpHeader.ymax.position, shpHeader.ymax.bigEndian);
    geoJson["bbox"][3] = boundingBoxYMax;

    var sniffedSpatialReference = establishSpatialReference(boundingBoxXMin, boundingBoxYMin, boundingBoxXMax, boundingBoxYMax);

    if (geoJson["crs"]["properties"]["name"] > "" && geoJson["crs"]["properties"]["name"] !== sniffedSpatialReference.toString()){
        try {
            throw new Error("Possible spatial reference mismatch. SR in .prj file doesn't seem to match coordinates found in .shp file.");
        }
        catch(e) {
            WorkerScript.sendMessage({"error": e});
        }
        finally {
            resetFeatures();
            return;
        }
    }

    if (geoJson["crs"]["properties"]["name"] === "") {
        geoJson["crs"]["properties"]["name"] = sniffedSpatialReference;
    }

    // geometry entries start at 100 after shape file header -------------------
    cursor = 100;

    if (shapeType !== undefined && shapeType !== null && shapeType !== 0 && shapeType.geojson !== null) {
        while (cursor < shapeFileByteLength) {
            var feature = getFeature(cursor);
            geoJson.features.push(feature);
        }
    }

    //console.log(JSON.stringify(geoJson));

    WorkerScript.sendMessage({"geojson": geoJson});

    resetFeatures();

}

function getFeature(thisCursor){

    //console.log("getFeature: ", thisCursor);

    var currentFeature = {};
    partsArray = [];
    pointsArray = [];

    currentFeature["type"] = "Feature";
    currentFeature["bbox"] = [];
    currentFeature["properties"] = {};
    currentFeature["shapefile_related"] = {};
    currentFeature["geometry"] = {
        "type": shapeType.geojson,
        "coordinates": []
    }

    console.log(JSON.stringify(currentFeature));

    currentFeature["properties"]["RecordNumber"] = shpDataArray.getInt32(thisCursor);
    thisCursor += 4;
    currentFeature["shapefile_related"]["Content Length"] = shpDataArray.getInt32(thisCursor);
    thisCursor += 4;
    currentFeature["shapefile_related"]["ShapeType"] = shpDataArray.getInt32(108, true);
    thisCursor += 4;
    currentFeature["bbox"] = []
    currentFeature["bbox"][0] = shpDataArray.getFloat64(thisCursor, true);
    thisCursor += 8;
    currentFeature["bbox"][1] = shpDataArray.getFloat64(thisCursor, true);
    thisCursor += 8;
    currentFeature["bbox"][2] = shpDataArray.getFloat64(thisCursor, true);
    thisCursor += 8;
    currentFeature["bbox"][3] = shpDataArray.getFloat64(thisCursor, true);
    thisCursor += 8;
    currentFeature["shapefile_related"]["numParts"] = shpDataArray.getInt32(thisCursor, true);
    thisCursor += 4;
    currentFeature["shapefile_related"]["numPoints"] = shpDataArray.getInt32(thisCursor, true);
    thisCursor += 4;


    if (currentFeature["shapefile_related"]["numParts"] > 1000) {
        try {
            throw new Error("This tool only supports shapefiles with less than 1000 parts.");
        }
        catch(e) {
            WorkerScript.sendMessage({"error": e});
        }
        finally {
            resetFeatures();
            return;
        }
    }

    if (currentFeature["shapefile_related"]["numParts"] > 0) {

        try {

            WorkerScript.sendMessage({"status": qsTr("Reading %1 features.".arg(featureCount))});

            var x = 0;

            for (x = 0; x < currentFeature["shapefile_related"]["numParts"]; x++) {
                var pointLocation = shpDataArray.getInt32(thisCursor, true);
                partsArray.push(pointLocation);
                thisCursor += 4;
            }

            console.log("partsArray.length: ", partsArray.length);

            var nP = currentFeature["shapefile_related"]["numPoints"] * 2;

            for (x = 0; x < nP; x++) {
                var point = shpDataArray.getFloat64(thisCursor, true);
                pointsArray.push(point);
                thisCursor += 8;
            }

//            console.log("pointsArray.length: ", pointsArray.length);

            for (x = 0; x < partsArray.length; x++) {

                if (shapeValue === 5) {
                   currentFeature["geometry"].coordinates[x] = [];
                }

                var pointStart = partsArray[x] * 2; // e.g. [0,320,333]

//                console.log("pointStart: ", pointStart);

                var lastPoint = (x === partsArray.length - 1) ? pointsArray.length : partsArray[x+1] * 2;
//                console.log("lastPoint: ", lastPoint)

                var coordinate = [];

                for (var pointCounter = pointStart; pointCounter < lastPoint; pointCounter++) {
//                    console.log("step: %1, pointCounter: %2, coord:%3, cLength:%4".arg(x).arg(pointCounter).arg(pointsArray[pointCounter]).arg(currentFeature["geometry"].coordinates[x].length));

                    coordinate.push(pointsArray[pointCounter]);

                    if (coordinate.length === 2) {

                        if (shapeValue === 5) {
                            currentFeature["geometry"].coordinates[x].push(coordinate);
                        }
                        else if (shapeValue === 3) {
                            currentFeature["geometry"].coordinates.push(coordinate);
                        }
                        else {

                        }
                        coordinate = [];
                    }
                }
            }
            featureCount ++;
        }
        catch(e) {
            WorkerScript.sendMessage({"error": e});
            resetFeatures();
        }
    }

//    console.log("currentFeature: ", JSON.stringify(currentFeature));

    // Set global cursor so next feature can be read by while loop -------------
    cursor = thisCursor;

//    console.log("cursor: ", cursor)

    return currentFeature;

}
