import QtQuick 2.0
import ArcGIS.AppFramework 1.0
import "../Portal"

FileFolder {

    id: tpkGetPKInfo

    // PROPERTIES //////////////////////////////////////////////////////////////

    property Portal portal
    property string fileName: "noname"
    property string fileExtension: ".pkinfo"

    property bool active

    signal complete(string fileStatus)

    // METHODS /////////////////////////////////////////////////////////////////

    function get(fName, itemId){
        active = true;
        fileName = fName;
        getPKInfo.url = "https://www.arcgis.com/sharing/content/items/" + itemId + '/item.pkinfo?token=' + portal.token;
        getPKInfo.send();
    }

    function cancel(){
        if(active){
            getPKInfo.abort();
            active = false;
        }
    }

    // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////////

    onComplete: {
        active = false;
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    property NetworkRequest getPKInfo: NetworkRequest{

        responseType: "xml"

        method: "GET"

        headers.userAgent: tpkGetPKInfo.portal.userAgent

        onReadyStateChanged: {

            if (readyState === NetworkRequest.ReadyStateComplete)
            {
                if (status === 200) {
                    tpkGetPKInfo.writeTextFile((tpkGetPKInfo.fileName + tpkGetPKInfo.fileExtension), responseText );
                    complete("pkinfo file successfully saved.");
                } else {
                    tpkGetPKInfo.writeTextFile((tpkGetPKInfo.fileName + tpkGetPKInfo.fileExtension), "failed to retrieve." );
                    complete("failed to retrieve pkinfo.");
                }
            }else{
            }
        }
    }

    // END /////////////////////////////////////////////////////////////////////
}
