import QtQuick 2.0
import QtQuick.Dialogs 1.2
import ArcGIS.AppFramework 1.0

import "../Portal"

Item {

    id: tpkCreatePItemFile

    // PROPERTIES //////////////////////////////////////////////////////////////

    property string defaultSaveToLocation: AppFramework.userHomePath + "/ArcGIS/My Tile Packages"
    property string fileName: ""
    property bool fileWritten: false
    property var jsonToFile: {}

    signal success(string path)

    // METHODS /////////////////////////////////////////////////////////////////

    function create(packageInfo){

        // packageInfo contains odd values that are purged when stringified
        // so have to stringify and then parse back into a clean JSON object.

        var modelJson = JSON.stringify(packageInfo);
        jsonToFile = JSON.parse(modelJson);

        fileName = _sanatizeTitle(jsonToFile["title"]);

        folderChooser.open();

    }

    function cancel(){

    }

    // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////////

    onFileWrittenChanged: {
        if(fileWritten){
            success("%1/%2".arg(fileFolder.path).arg(fileName));
            fileWritten = false;
        }
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    FileFolder {
        id: fileFolder
        path: defaultSaveToLocation
    }

    //--------------------------------------------------------------------------

    FileDialog {
        id: folderChooser
        title: "Please choose a folder to save to"
        selectFolder: true
        modality: Qt.WindowModal
        folder: defaultSaveToLocation
        onAccepted: {
            fileFolder.path = AppFramework.resolvedPath(folderChooser.fileUrl);
            folderChooser.folder = AppFramework.resolvedPath(folderChooser.fileUrl);
            fileWritten = fileFolder.writeJsonFile(fileName, jsonToFile);
            folderChooser.close();
        }
        onRejected: {
            fileFolder.path = defaultSaveToLocation;
            folderChooser.close();
        }
    }

    // INTERNAL METHODS ////////////////////////////////////////////////////////

    function _sanatizeTitle(inText){
        var title = inText !== "" ? inText.replace(/[^a-zA-Z0-9]/g,"_").toLocaleLowerCase() : "no_title_available";
        return title /*+ "_" + AppFramework.createUuidString(2)*/ + ".pitem";
    }

    // END /////////////////////////////////////////////////////////////////////
}
