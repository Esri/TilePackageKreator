import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

FileFolder {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: historyManager

    path: AppFramework.userHomePath + "/ArcGIS/TilePackageKreator/History"

    property string historyFile: historyManager.path + "/history.json"

    property string uploadHistoryKey: "upload"
    property string exportHistoryKey: "export"

    property var currentHistory: null

    // METHODS /////////////////////////////////////////////////////////////////

    function readHistory(id){

        if(historyManager.makePath(historyManager.path)){
            if(!historyManager.fileExists(historyFile)){
                historyManager.writeTextFile(historyFile,"");
            }
        }

        var h = historyManager.readTextFile(historyFile);

        if(h === "" || h === null){
             currentHistory = {};
        }
        else{
            currentHistory = JSON.parse(h);
        }

        if( id  !== undefined && id !== null && id !== ""){
            if(currentHistory.hasOwnProperty(id) && currentHistory[id].length > 0){
                return currentHistory[id];
            }
            else{
                return null;
            }
        }
        else{
            return null;
        }
    }

    // -------------------------------------------------------------------------

    function writeHistory(id, data){
        readHistory();
        if(!currentHistory.hasOwnProperty(id)){
            currentHistory[id] = [];
        }

        if(data !== "" && data !== undefined && data !== null){
            currentHistory[id].push(data);
        }
        else{
            currentHistory[id] = [];
        }

        historyManager.writeTextFile(historyFile, JSON.stringify(currentHistory));
    }

    // -------------------------------------------------------------------------

    function deleteHistory(id){
        writeHistory(id, "");
    }

    // END /////////////////////////////////////////////////////////////////////
}
