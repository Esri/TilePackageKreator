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

    // A -----------------------------------------------------------------------

    readonly property string aboutAndHelp: qsTr("About and Help")
    readonly property string aboutTheApp: qsTr("About the app")
    readonly property string aboutTheAppDesc: qsTr("This button opens up a dialog that provides information about this application. The action on this button will only work when the button is enabled via the application.")
    readonly property string add: qsTr("Add")
    readonly property string addTileService: qsTr("Add a tile service manually")
    readonly property string addTileServiceDesc: qsTr("This control will reveal an input form which the user can enter a url for a tile service to add to the list.")
    readonly property string alertMessageDesc: qsTr("This alert message provides information about where .pitem files are saved, or if there was an error.")
    readonly property string animatedSpinner: qsTr("animated spinner")
    readonly property string animatedSpinnerDesc: qsTr("This is an animated spinner that appears when network queries are in progress.")


    // B -----------------------------------------------------------------------
    readonly property string back: qsTr("Back")
    readonly property string bookmarks: qsTr("Bookmarks")
    readonly property string browse: qsTr("Browse")
    readonly property string browseForFile: qsTr("Browse for file")
    readonly property string browseOrgTilePackages: qsTr("Browse Organization Tile Packages")
    readonly property string bufferRadius: qsTr("Buffer Radius")
    readonly property string bufferRadiusDesc: qsTr("Enter a buffer radius.")


    // C -----------------------------------------------------------------------
    readonly property string cancel: qsTr("Cancel")
    readonly property string cancelling: qsTr("Cancelling")
    readonly property string cancellingUpload: qsTr("Cancelling Upload.")
    readonly property string contextMenuDesc: qsTr("Context menu for this service.")
    readonly property string checkingSpatialReference: qsTr("Checking Spatial Reference")
    readonly property string create: qsTr("Create")
    readonly property string createNewTilePackage: qsTr("Create New Tile Package")
    readonly property string createTilePackage: qsTr("Create Tile Package")
    readonly property string createPItem: qsTr("Create .pitem")
    readonly property string createPItemDesc: qsTr("This menu item will open up a file dialog and save a pitem file to the location specified in the dialog.")
    readonly property string creating: qsTr("Creating")
    readonly property string creatingBufferGeometry: qsTr("Creating buffer geometry")
    readonly property string currentTileService: qsTr("Current Tile Service")
    readonly property string cursorCoord: qsTr("Cursor Coordinate")
    readonly property string cursorCoordDesc: qsTr("This text denotes the current latitude and longitude position of the mouse cursor on the map.")


    // D -----------------------------------------------------------------------
    readonly property string defaultTPKDesc: qsTr("Created via Tile Export. Update Description using Browse or online at link below.")
    readonly property string deleteBookmark: qsTr("Delete Bookmark")
    readonly property string deleteExtent: qsTr("Delete Extent")
    readonly property string deleteHistory: qsTr("Delete History")
    readonly property string description: qsTr("Description")
    readonly property string descriptionCopyPaste: qsTr("Copy and paste description text here.")
    readonly property string descriptionCharCountDesc: qsTr("This text displays the number of charcters left available in the description text area.")
    readonly property string descriptionTextAreaDesc: qsTr("Enter a description of the tile package for the online item.")
    readonly property string desiredLevelsDesc: qsTr("This text is updated when the desired levels slider values are updated.")
    readonly property string doNotShare: qsTr("Do not share")
    readonly property string downloading: qsTr("Downloading.")
    readonly property string downloadComplete: qsTr("Download Complete.")
    readonly property string dragTPKFile: qsTr("Drag .tpk file here")
    readonly property string drawAnExtentOrPath: qsTr("Draw an extent or path")
    readonly property string drawingExtent: qsTr("Drawing Extent")
    readonly property string drawingPath: qsTr("Drawing Path")
    readonly property string drawRectangle: qsTr("Draw Rectangle")
    readonly property string drawPath: qsTr("Draw Path")
    readonly property string drawPolygon: qsTr("Draw Polygon")


    // E -----------------------------------------------------------------------
    readonly property string enterATitle: qsTr("Enter a title")
    readonly property string enterUrlForTileService: qsTr("Enter a url for a tile service.")
    readonly property string estimatedOutputSize: qsTr("Estimated Output Size")
    readonly property string estimatedOutputSizeDesc: qsTr("This text denotes the estimated output size for the current geometry and zoom levels. Not currently available with paths.")
    readonly property string estimatingTPKSize: qsTr("Estimating tile package size.")
    readonly property string everyonePublic: qsTr("Everyone (Public)")
    readonly property string exportAndUploadHistory: qsTr("Export and Upload History")
    readonly property string exportAndUploadHistoryDesc: qsTr("This button will open the export and upload history view. The action on this button will only work when the button is enabled via the application.")
    readonly property string exportMayFailWarning: qsTr("Export may fail with this many levels if extent is too large.")
    readonly property string exportHistory: qsTr("Export History")
    readonly property string exportCancelled: qsTr("Export Cancelled.")
    readonly property string exportComplete: qsTr("Export Complete.")
    readonly property string exportFailed: qsTr("Export Failed.")
    readonly property string exportStarted: qsTr("Export Started.")
    readonly property string exportUploadCancelled: qsTr("Export Upload Cancelled.")
    readonly property string exportUploadFailed: qsTr("Export Upload Failed.")
    readonly property string extentOrPathDrawn: qsTr("Extent / Path Drawn")


    // F -----------------------------------------------------------------------
    readonly property string feedback: qsTr("Feedback")
    readonly property string feedbackDesc: qsTr("This button opens up a dialog that allows a user to submit feedback on the application. The action on this button will only work when the button is enabled via the application.")


    // G -----------------------------------------------------------------------
    readonly property string goBackToPreviousView: qsTr("Go Back to previous view")
    readonly property string goBackToPreviousViewDesc: qsTr("This button will take you back to the previous view. The action on this button will only work when the button is enabled via the application.")

    // H -----------------------------------------------------------------------
    readonly property string history: qsTr("History")


    // I -----------------------------------------------------------------------


    // J -----------------------------------------------------------------------


    // K -----------------------------------------------------------------------


    // L -----------------------------------------------------------------------
    readonly property string localTilePackage: qsTr("Local Tile Package")


    // M -----------------------------------------------------------------------
    readonly property string metadata: qsTr("Metadata")
    readonly property string metadataDialogDesc: qsTr("This is a dialog that displays metadata for a selected tile service.")
    readonly property string metatdataTextDesc: qsTr("Metadata text")


    // N -----------------------------------------------------------------------
    readonly property string newTilePackage: qsTr("New Tile Package")
    readonly property string next: qsTr("Next")
    readonly property string noDesc: qsTr("No Description")
    readonly property string notAvailableWithPathsOrPolygons: qsTr("Not Available with Paths or Polygons")
    readonly property string noExportTileServices: qsTr("No export tile services are available.")
    readonly property string noOrgTileServices: qsTr("There are no tile packages available.")
    readonly property string noTitle: qsTr("No Title")
    readonly property string notWebMercator: qsTr("NOT WEB MERCATOR")
    readonly property string numberOfZoomLevels: qsTr("Number of Zoom Levels")


    // O -----------------------------------------------------------------------
    readonly property string or: qsTr("or")
    readonly property string organizationTilePackages: qsTr("Organization Tile Packages")

    // P -----------------------------------------------------------------------


    // Q -----------------------------------------------------------------------
    readonly property string queryingServices: qsTr("Querying Services. Please wait.")

    // R -----------------------------------------------------------------------
    readonly property string redrawLastEnvelope: qsTr("Redraw last envelope.")
    readonly property string redrawLastPath: qsTr("Redraw last path")
    readonly property string redrawLastPolygon: qsTr("Redraw last polygon")


    // S -----------------------------------------------------------------------
    readonly property string saveAsBookmark: qsTr("Save as bookmark")
    readonly property string saveTo: qsTr("Save To")
    readonly property string saveToDesc: qsTr("This button will open a file dialog chooser that allows the user to select the folder to save the tile package to locally.")
    readonly property string saveToLocationDesc: qsTr("Selected save to location")
    readonly property string saveTpkLocally: qsTr("Save tile package locally")
    readonly property string searchAddressOrLatLon: qsTr("Search address or @lat,lon")
    readonly property string selectAnOperation: qsTr("Select an Operation")
    readonly property string selectTileService: qsTr("Select tile service to be used as the source for the tile package")
    readonly property string selectTileServiceDesc: qsTr("This control will select the tile service to export tiles from and will transition to the export area and details selection view.")
    readonly property string shareThisItemWith: qsTr("Share this item with:")
    readonly property string sharingItem: qsTr("Sharing item.")
    readonly property string signOut: qsTr("Sign out")
    readonly property string signOutDesc: qsTr("This button will sign the user out of the application and return to the sign in screen. The action on this button will only work when the button is enabled via the application.")
    readonly property string spatialReferenceDesc: qsTr("This text denotes the tile service's spatial reference.")
    readonly property string statusTextDesc: qsTr("This status text will update as services are discovered and then queried for the ability to export tiles.")

    // T -----------------------------------------------------------------------
    readonly property string tileServiceSourceDesc: qsTr("This text denotes whether the tile service is from an Esri source or an external source.")
    readonly property string tileServiceThumbnailDesc: qsTr("Tile service thumbnail image.")
    readonly property string tileServiceTitleDesc: qsTr("Title of the tile service.")
    readonly property string tileServiceUrlExample: qsTr("Enter url (e.g. http://someservice.gov/arcgis/rest/services/example/MapServer)")
    readonly property string title: qsTr("Title")
    readonly property string tpkFilesOnly: qsTr(".tpk files only please")


    // U -----------------------------------------------------------------------
    readonly property string updatesAvailable: qsTr("Updates Available")
    readonly property string upload: qsTr("Upload")
    readonly property string uploaded: qsTr("Uploaded")
    readonly property string uploading: qsTr("Uploading")
    readonly property string uploadingToPortal: qsTr("Uploading to portal.")
    readonly property string uploadCancelled: qsTr("Upload Cancelled")
    readonly property string uploadHistory: qsTr("Upload History")
    readonly property string uploadTilePackage: qsTr("Upload Local Tile Package")
    readonly property string uploadToArcGIS: qsTr("Upload tile package to ArcGIS")
    readonly property string useDifferentFile: qsTr("Use a different file")


    // V -----------------------------------------------------------------------
    readonly property string viewOnArcgis: qsTr("View on ArcGIS")
    readonly property string viewOnArcgisOrPortalDesc: qsTr("This menu item will open up a web browser and load the ArcGIS or Portal item for this tile service.")
    readonly property string viewMetadata: qsTr("View Metadata")
    readonly property string viewMetadataDesc: qsTr("This menu item will open up a dialog window and display metadata associated with this tile service.")
    readonly property string viewOnPortal: qsTr("View on Portal")
    readonly property string viewRestService: qsTr("View REST Service")
    readonly property string viewOnlineService: qsTr("View Service")
    readonly property string viewOnlineServiceDesc: qsTr("This menu item will open up a web browser and load the REST description for this tile service.")


    // W -----------------------------------------------------------------------
    readonly property string webMercator: qsTr("Web Mercator")


    // X -----------------------------------------------------------------------

    // Y -----------------------------------------------------------------------
    readonly property string yourOrg: qsTr("Your organization")


    // Z -----------------------------------------------------------------------
    readonly property string zoomIn: qsTr("Zoom In")
    readonly property string zoomLevel: qsTr("Zoom Level")
    readonly property string zoomOut: qsTr("Zoom Out")
    readonly property string zoomLevelDesc: qsTr("This text indicates the current zoom level of the map.")


    // Errors ------------------------------------------------------------------

    readonly property string serviceNotAddedError: qsTr("The service wasn't added. There may be a problem with the service or url entered.")
    readonly property string noFileChosen: qsTr("no file chosen")
    readonly property string tpkWithThatNameAlreadyExistsError: qsTr("A tpk file with that name already exists.")
    readonly property string uploadFailedError: qsTr("Upload Failed")

    // Dynamic Strings ---------------------------------------------------------
    property string completeReturnToX: qsTr("Complete. <a href='%1?isShared=%2&isOnline=%3&itemId=%4'>Return to %5</a>")
    property string downloadedToX: qsTr("Downloaded to %1")
    property string estimatedSizeXNumOfTilesX: qsTr("Estimated Size: %1 MB, Number of Tiles: %2")
    property string fileSavedToX: qsTr("File saved to %1")
    property string foundXTotalServices: qsTr("Found %1 total services. Querying each for export tile ability.")
    property string tilesXSizeX: qsTr("Tiles: %1 Size: %2")
    property string xUpdatesAvaliable: qsTr("%1 Updates are available")
    property string xUpdatesAvaliableDesc: qsTr("This button is enabled when there are updates available to the application. The action on this button will only work when the button is enabled via the application.")
    property string uploadedSeeX: qsTr("Uploaded. <a href=\"%1\">See Tile Package Item</a>")
    property string uploadingAndSharedSeeX: qsTr("Uploaded and Shared. <a href=\"%1\">See Tile Package Item</a>")
}
