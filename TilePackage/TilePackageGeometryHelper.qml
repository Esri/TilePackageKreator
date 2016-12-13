import QtQuick 2.0
import ArcGIS.AppFramework 1.0

Item {

    id: tpkGeometryHelper

    // PROPERTIES //////////////////////////////////////////////////////////////

    readonly property url esriGeometryServiceUrl: "http://tasks.arcgisonline.com/ArcGIS/rest/services/Geometry/GeometryServer"
    readonly property url areasAndLengthsUrl: esriGeometryServiceUrl + "/areasAndLengths"
    readonly property url bufferUrl: esriGeometryServiceUrl + "/buffer"
    readonly property url projectUrl: esriGeometryServiceUrl + "/project"

    property bool active

    signal complete(var geometries)
    signal error(var err)
    signal success()

    // METHODS /////////////////////////////////////////////////////////////////

    function buffer(g, sr, bufferDistance){

        var requestInfo = {
            "f": "pjson",
            "geometries": JSON.stringify(g),
            "inSR": sr,
            "outSR": sr,
            "bufferSR": 3857,
            "unit": 9001,
            "distances": bufferDistance,
            "unionResults": true
        }

        geometryNetworkRequest.url = bufferUrl;
        geometryNetworkRequest.send(requestInfo);
        active = true;
    }

    function project(g, sr){
        var requestInfo = {
            "f": "json"
        }
    }

    function cancel(){
        geometryNetworkRequest.abort();
    }

    // SIGNAL IMPLEMENTATION ///////////////////////////////////////////////////

    onComplete: {
        //console.log(JSON.stringify(geometries));
    }

    onError: {

    }

    onSuccess: {

    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    NetworkRequest {

        id: geometryNetworkRequest

        responseType: "json"

        method: "POST"

        onReadyStateChanged: {

            if (readyState === NetworkRequest.ReadyStateComplete)
            {
                tpkGeometryHelper.active = false;

                if (status === 200) {
                    console.log(JSON.stringify(response));
                   // var responseJson = JSON.parse(response);

                    if(response.hasOwnProperty("geometries")){
                        tpkGeometryHelper.complete(response);
                    }
                    else{
                        console.log('no geometry or error');
                        tpkGeometryHelper.error({"message": "no geometry returned"});
                    }
                }
            }
            else{
            }
        }
    }

    // END /////////////////////////////////////////////////////////////////////
}
