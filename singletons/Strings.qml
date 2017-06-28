/* Copyright 2017 Esri
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

pragma Singleton
import QtQuick 2.7

QtObject {
    id: strings

    readonly property string nextButton: qsTr("Next") +  " &#187;"
    readonly property string add: qsTr("Add")
    readonly property string cancel: qsTr("Cancel")
    readonly property string back: qsTr("Back")
    readonly property string or: qsTr("or")
    readonly property string cancelling: qsTr("Cancelling")
    readonly property string uploading: qsTr("Uploading")
    readonly property string upload: qsTr("Upload")
    readonly property string uploadCancelled: qsTr("Upload Cancelled")
    readonly property string webMercator: qsTr("Web Mercator")
    readonly property string notWebMercator: qsTr("NOT WEB MERCATOR")

    readonly property string viewOnArcgis: qsTr("View on ArcGIS")
    readonly property string viewOnPortal: qsTr("View on Portal")
    readonly property string viewRestService: qsTr("View REST Service")
    readonly property string viewOnlineService: qsTr("View Service")
    readonly property string createPItem: qsTr("Create .pitem")

    readonly property string createNewTilePackage: qsTr("Create New Tile Package")
    readonly property string uploadTilePackage: qsTr("Upload Local Tile Package")

    readonly property string useDifferentFile: qsTr("Use a different file")
    readonly property string browseForFile: qsTr("Browse for file")
    readonly property string tpkFilesOnly: qsTr(".tpk files only please")
    readonly property string dragTPKFile: qsTr("Drag .tpk file here")
    readonly property string queryingServices: qsTr("Querying Services. Please wait.")
    readonly property string selectTileService: qsTr("Select tile service to be used as the source for the tile package")
    readonly property string addTileService: qsTr("Add a tile service manually")
    readonly property string tileServiceUrlExample: qsTr("Enter url (e.g. http://someservice.gov/arcgis/rest/services/example/MapServer)")
    readonly property string noTileServices: qsTr("No export tile services are available.")
    readonly property string checkingSpatialReference: qsTr("Checking Spatial Reference")

    readonly property string numberOfZoomLevels: qsTr("Number of Zoom Levels")

    // Errors ------------------------------------------------------------------

    readonly property string serviceNotAddedError: qsTr("The service wasn't added. There may be a problem with the service or url entered.")
    readonly property string noFileChosen: qsTr("no file chosen")
    readonly property string tpkWithThatNameAlreadyExistsError: qsTr("A tpk file with that name already exists.")
    readonly property string uploadFailedError: qsTr("Upload Failed")

    // Dynamic Strings ---------------------------------------------------------

    property string fileSavedToX: qsTr("File saved to %1")
    property string foundXTotalServices: qsTr("Found %1 total services. Querying each for export tile ability.")
}
