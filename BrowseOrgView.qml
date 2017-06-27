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

import QtQuick 2.6
import QtQuick.Controls 2.1
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
//------------------------------------------------------------------------------
import "Portal"
import "TilePackage"
//------------------------------------------------------------------------------

Item {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: browseOrganizationTpksView

    property Portal portal
    property Config config
    property bool busy: false
    property double gridMargin: config.availableServicesView.gridMargin
    property var currentTileService: null
    property int thumbnailWidth: config.thumbnails.width
    property int thumbnailHeight: config.thumbnails.height
    property string searchQuery: '(type:("Tile Package") AND group:(access:org OR access:private))'
    property ListModel servicesListModel: ListModel {}

    // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////////

    Component.onCompleted: {
        console.log(tileServicesSearch.portal.restUrl + "/search");
        tileServicesSearch.start();
        activityIndicator.visible = true;
        rotator.target = refreshSpinner;
        rotator.start();
    }

    //--------------------------------------------------------------------------

    StackView.onActivating: {
        mainView.appToolBar.enabled = true;
        mainView.appToolBar.historyButtonEnabled = true;
        mainView.appToolBar.backButtonEnabled = true;
        mainView.appToolBar.backButtonVisible = true;
        mainView.appToolBar.toolBarTitleLabel = qsTr("Browse Organization Tile Packages")
    }

    // UI //////////////////////////////////////////////////////////////////////

    Rectangle {
        id: servicesGrid
        color: "white"
        anchors.fill: parent
        Accessible.role: Accessible.Pane

        Rectangle {
            id: activityIndicator
            anchors.fill: parent
            visible: false
            color: config.subtleBackground
            opacity: .8
            z: 1000
            Accessible.role: Accessible.Pane

            Item{
                width: sf(80)
                height: sf(80)
                anchors.centerIn: parent
                Accessible.role: Accessible.Pane

                Text{
                    id: refreshSpinner
                    anchors.centerIn: parent
                    font.pointSize: config.largeFontSizePoint * 3
                    color: "#888"
                    font.family: iconFont
                    text: icons.spinner2

                    Accessible.role: Accessible.Animation
                    Accessible.name: qsTr("animated spinner")
                    Accessible.description: qsTr("This is an animated spinner that appears when network queries are in progress.")
                }
            }
        }

        GridView {
            id: servicesGridView
            anchors.fill: parent
            clip: true
            flow: GridView.FlowLeftToRight
            cellHeight: _returnCellWidth()
            cellWidth: _returnCellWidth()
            model: servicesListModel
            delegate: tileServiceDelegate
            //highlight: highlight
            //highlightFollowsCurrentItem: false
            currentIndex: -1
            z: 999
        }
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    Component {
        id: tileServiceDelegate

        Item {

            Rectangle {
                id: tileContainer
                color: "transparent"
                width: servicesGridView.cellWidth
                height: servicesGridView.cellHeight
                Accessible.role: Accessible.Pane

                MouseArea {
                    id: tileClick
                    anchors.fill: parent

                    onClicked: {
                        servicesGridView.currentIndex = index;
                    }

                    onDoubleClicked: {
                    }

                    Accessible.ignored: true // ignored at this point as clicking doesn't do anything currently.
                    /*
                    Accessible.role: Accessible.Button
                    Accessible.name: qsTr("Select this tile service.")
                    Accessible.onPressAction: {
                        if(enabled && visible){
                            clicked(null);
                        }
                    }*/
                }

                Rectangle {
                    id: tileContent
                    color: config.availableServicesView.tileItemBackgroundColor
                    border.color: config.availableServicesView.tileItemBorderColor
                    border.width: gridMargin / 2
                    anchors.fill: parent
                    anchors.margins: gridMargin / 2
                    Accessible.role: Accessible.Pane

                    Rectangle {
                        id: innerTile
                        anchors.fill: parent
                        anchors.margins: gridMargin / 2 + sf(5)
                        Accessible.role: Accessible.Pane

                        ColumnLayout {
                            spacing: 0
                            anchors.fill: parent

                            Image {
                                Layout.preferredWidth: innerTile.width
                                Layout.preferredHeight: (innerTile.width / thumbnailWidth * thumbnailHeight)
                                fillMode: Image.PreserveAspectFit
                                source: (thumbnail !== null && thumbnail !== undefined && thumbnail !== "") ?
                                        browseOrganizationTpksView.portal.restUrl + "/content/items/" + id + "/info/" + thumbnail + (browseOrganizationTpksView.portal.signedIn ? "?token=" + browseOrganizationTpksView.portal.token : "")
                                        : "images/no_thumbnail.png"

                                Accessible.role: Accessible.Graphic
                                Accessible.name: qsTr("Thumbnail for %1".arg(title))
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "#fafafa"
                                Accessible.role: Accessible.Pane

                                Text {
                                    text: title
                                    anchors.fill: parent
                                    font {
                                        pointSize: config.smallFontSizePoint
                                    }
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                    Accessible.role: Accessible.StaticText
                                    Accessible.name: text
                                    Accessible.description: qsTr("This is the title of the tile service.")
                                }
                            }

                            Rectangle {
                                id: tileMenu
                                color: "white"
                                Layout.preferredHeight: sf(30)
                                Layout.fillWidth: true
                                Accessible.role: Accessible.Pane

                                RowLayout{
                                    anchors.fill: parent
                                    spacing:0
                                    Rectangle {
                                        id: tileWebMercIndicatorContainer
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Accessible.role: Accessible.Pane

                                        Text {
                                            id: tileWebMercIndicator
                                            anchors.fill: parent
                                            anchors.leftMargin: sf(10)
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignLeft
                                            font.pointSize: config.xSmallFontSizePoint
                                            text: isWebMercator ? "Web Mercator" : "NOT Web Mercator"
                                            color: isWebMercator ? "#007ac2" : "red"

                                            Accessible.role: Accessible.StaticText
                                            Accessible.name: text
                                            Accessible.description: qsTr("Denotes whether the tile package is or is not projected in the web mercator spatial reference.")
                                        }
                                    }

                                    Rectangle {
                                        id: tileProviderTypeContainer
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true

                                        Text {
                                            id: tileProviderType
                                            anchors.fill: parent
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignHCenter
                                            font.pointSize: config.xSmallFontSizePoint
                                            text: access
                                            color: (access === "org") ? "#007ac2" : "#222"

                                            Accessible.role: Accessible.StaticText
                                            Accessible.name: text
                                            Accessible.description: qsTr("Denotes the access level for the tile package")
                                        }
                                    }

                                    Button {
                                        id: tileMenuBtn
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: parent.height

                                        background: Rectangle {
                                            anchors.fill: parent
                                            color: "white"
                                            radius: 0
                                            Image {
                                                id: tileMenuBtnIcon
                                                source: "images/menu.png"
                                                width: sf(20)
                                                height: sf(20)
                                                anchors.centerIn: parent
                                                Accessible.ignored: true
                                            }
                                            ColorOverlay {
                                                anchors.fill: tileMenuBtnIcon
                                                source: tileMenuBtnIcon
                                                color: hovered ? app.info.properties.mainButtonBackgroundColor : "#ccc"
                                                Accessible.ignored: true
                                            }
                                        }

                                        onClicked: {
                                            tileMenuMenu.popup();
                                        }

                                        Accessible.role: Accessible.Button
                                        Accessible.name: qsTr("Tile Package Context Menu")
                                        Accessible.description: qsTr("This button opens up a context menu with options related to this tile package.")
                                    }
                                }
                            }

                            Menu {
                                id: tileMenuMenu
                                property int tileIndex: index

                                MenuItem {
                                    text: qsTr("View Metadata")
                                    onTriggered: {

                                        var item = servicesListModel.get(tileMenuMenu.tileIndex);

                                        for(var metadata in item){
                                            if( item[metadata]!== undefined ){
                                                metadataTextArea.append("<h2>" + metadata + "</h2>");
                                                if(typeof item[metadata] !== "object"){
                                                    metadataTextArea.append("<p>" + JSON.stringify(item[metadata]) + "</p>");
                                                }else{
                                                    var subdata = item[metadata].get(0);
                                                    if(subdata !== undefined){
                                                        metadataTextArea.append("<p>" + JSON.stringify(subdata) + "</p>");
                                                    }
                                                }
                                            }
                                        }
                                        metadataTextArea.cursorPosition = 0;
                                        metadataDialog.open();
                                    }
                                    Accessible.role: Accessible.MenuItem
                                    Accessible.name: text
                                    Accessible.description: qsTr("This menu item will open up a dialog window and display metadata associated with this tile service.")
                                }

                                MenuItem {
                                    text: qsTr("Download via Web Browser")
                                    onTriggered: {
                                        var baseUrl = !portal.isPortal ? "http://www.arcgis.com/sharing/rest/content" : portal.restUrl + "/content";
                                        Qt.openUrlExternally( baseUrl + "/items/" + servicesListModel.get(tileMenuMenu.tileIndex).id + "/data?token="+ portal.token);
                                    }
                                    Accessible.role: Accessible.MenuItem
                                    Accessible.name: text
                                    Accessible.description: qsTr("This menu item will open up a web browser and download the tile package to your local machine.")
                                }

                                MenuItem {
                                    text: !portal.isPortal ? qsTr("View on ArcGIS") : qsTr("View on Portal")
                                    onTriggered: {
                                        var baseUrl = !portal.isPortal ? "http://www.arcgis.com/home" : portal.portalUrl + "/home";
                                        Qt.openUrlExternally( baseUrl + "/item.html?id=" + servicesListModel.get(tileMenuMenu.tileIndex).id + "&token="+ portal.token);
                                    }
                                    Accessible.role: Accessible.MenuItem
                                    Accessible.name: text
                                    Accessible.description: qsTr("This menu item will open up a web browser and load the ArcGIS or Portal item for this tile service.")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    Dialog {
        id: metadataDialog
        visible: false
        title: "Metadata"
        modality: Qt.WindowModal

        Accessible.role: Accessible.Dialog
        Accessible.name: title
        Accessible.description: qsTr("This is a dialog that displays metadata for a selected tile service.")

        contentItem: Rectangle {
            color: config.subtleBackground
            anchors.fill: parent
            width: browseOrganizationTpksView.parent.width - sf(10)
            height: browseOrganizationTpksView.parent.height - sf(10)
            implicitWidth: browseOrganizationTpksView.parent.width - sf(10)
            implicitHeight: browseOrganizationTpksView.parent.height - sf(10)

            ColumnLayout {
                spacing: 1
                anchors.fill: parent

                Rectangle {
                    Layout.preferredHeight: sf(60)
                    Layout.fillWidth: true
                    Accessible.role: Accessible.Pane

                    RowLayout {
                        spacing: 0
                        anchors.fill: parent

                        Text {
                            id: metadataTitle
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            text: "Metadata"
                            color: app.info.properties.toolBarBackgroundColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            Accessible.role: Accessible.Heading
                            Accessible.name: text
                        }

                        Button {
                            id: closeBtn
                            Layout.preferredWidth: sf(60)
                            Layout.fillHeight: true
                            background: Rectangle {
                            anchors.fill: parent
                            color: "white"
                            radius: 0
                                Image {
                                    id: closeBtnIcon
                                    source: "images/process_failed.png"
                                    width: parent.width - sf(40)
                                    fillMode: Image.PreserveAspectFit
                                    anchors.centerIn: parent
                                    Accessible.ignored: true
                                }
                                ColorOverlay {
                                    anchors.fill: closeBtnIcon
                                    source: closeBtnIcon
                                    color: closeBtn.pressed ? app.info.properties.mainButtonPressedColor : app.info.properties.mainButtonBackgroundColor
                                    Accessible.ignored: true
                                }
                            }

                            onClicked: {
                                metadataTextArea.text = "";
                                metadataTitle.text = "Metadata";
                                metadataDialog.close();
                            }

                            Accessible.role: Accessible.Button
                            Accessible.name: qsTr("Close Dialog")
                            Accessible.onPressAction: {
                                if(metadataDialog.visible){
                                    clicked();
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Accessible.role: Accessible.Pane

                    TextArea {
                        id: metadataTextArea
                        anchors.fill: parent
                        anchors.margins: sf(10)
                        text: ""
                        color: app.info.properties.toolBarBackgroundColor
                        readOnly: true
                        textFormat: Text.RichText
                        onLinkActivated: {
                            Qt.openUrlExternally(link);
                        }
                        Accessible.role: Accessible.StaticText
                        Accessible.name: qsTr("Metadata text")
                        Accessible.multiLine: true
                        Accessible.readOnly: true
                    }
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: highlight

        Rectangle {
            color: "transparent"
            width: sf(servicesGridView.cellWidth)
            height: sf(servicesGridView.cellHeight)
            x: servicesGridView.currentItem.x
            y: servicesGridView.currentItem.y
            z: 1000
            Accessible.ignored: true

            Rectangle {
                id: highlightRect
                color: "transparent"
                anchors.fill: parent
                anchors.margins: sf(gridMargin / 2)
                visible: true
                border.width: sf(1)
                border.color: config.availableServicesView.highlightColor
            }

            Rectangle {
                width: sf(servicesGridView.cellWidth / 6)
                height: sf(servicesGridView.cellWidth / 6)
                radius: width / 2
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: sf(15)
                anchors.leftMargin: sf(15)
                Image {
                    id: tileSelectedIcon
                    source: "images/checkmark_inverted.png"
                    width: parent.width - sf(2)
                    height: parent.width - sf(2)
                    anchors.centerIn: parent
                    visible: true
                }
                ColorOverlay {
                    source: tileSelectedIcon
                    anchors.fill: tileSelectedIcon
                    color: config.availableServicesView.highlightColor
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    RotationAnimation {
        id: rotator
        direction: RotationAnimation.Counterclockwise
        from: 360
        to: 0
        duration: 2000
        property: "rotation"
        loops: Animation.Infinite
    }

    //--------------------------------------------------------------------------

    PortalSearch {

        id: tileServicesSearch

        portal: browseOrganizationTpksView.portal
        q: searchQuery
        sortField: "access"
        sortOrder: "asc"

        onSuccess: {
            response.results.forEach(function (result) {
                try{
                    console.log(JSON.stringify(result));
                    if (!result.description) {
                        result.description = "";
                    }

                    console.log(result.thumbnail);

                    if(!result.hasOwnProperty("thumbnail")){
                        result["thumbnail"] = "";
                    }

                    result.isWebMercator = _isWebMercator(result.spatialReference);

                    servicesListModel.append(result);
                }
                catch(error){
                    console.log(error);
                }

            })

            if (response.nextStart > 0) {
                search(response.nextStart);
            }
            else {
                busy = false;
                if (activityIndicator.visible === true) {
                    activityIndicator.visible = false;
                }
                rotator.stop();
            }
        }

        onFailed: {
        }

        function start() {
            servicesListModel.clear();
            busy = true;
            search();
        }
    }

    // METHODS /////////////////////////////////////////////////////////////////

    function _returnCellWidth() {

        var width;

        if (app.width < 400) {
            width = app.width;
        }

        if (app.width >= 400 && app.width < 700) {
            width = app.width / 2;
        }

        if (app.width >= 700 && app.width < 1000) {
            width = app.width / 3;
        }

        if (app.width >= 1000 && app.width < 1500) {
            width = app.width / 4;
        }

        if (app.width >= 1500) {
            width = app.width / 5;
        }

        return width
    }

    //--------------------------------------------------------------------------

    function _buttonStates(control) {

        if (control.pressed) {
            return app.info.properties.mainButtonPressedColor;
        } else if (!control.enabled) {
            return "#888";
        } else {
            return app.info.properties.mainButtonBackgroundColor;
        }

    }

    //--------------------------------------------------------------------------

    function _exportTilesAllowed(serviceInfo) {

        if (serviceInfo.hasOwnProperty("exportTilesAllowed")) {
            if (serviceInfo.exportTilesAllowed === false) {
                return false;
            } else {
                return true;
            }
        } else {
            return false;
        }

    }

    //--------------------------------------------------------------------------

    function _isWebMercator(sr){

        // This needs to be replaced with the better logic from TilePackageUpload
        // See #135

        if (sr === config.webMercSR || sr === config.webMercLatestWKID.toString() || sr === config.webMercWKID.toString()){
            return true;
        }
        else{
            return false;
        }
    }

    // END /////////////////////////////////////////////////////////////////////
}
