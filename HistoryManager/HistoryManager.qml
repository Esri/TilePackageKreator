/* Copyright 2016 Esri
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

import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
//------------------------------------------------------------------------------

FileFolder {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: historyManager

    path: AppFramework.userHomePath + "/ArcGIS/TilePackageKreator/History"

    property string historyFile: historyManager.path + "/history.json"

    property string uploadHistoryKey: "upload"
    property string exportHistoryKey: "export"

    property var currentHistory: null

    // METHODS /////////////////////////////////////////////////////////////////

    function getHistory(){
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
    }

    // -------------------------------------------------------------------------

    function readHistory(id){
        if(currentHistory === null){
            getHistory();
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
