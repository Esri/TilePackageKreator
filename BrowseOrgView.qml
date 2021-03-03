/* Copyright 2021 Esri
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

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
//------------------------------------------------------------------------------
import "Portal"
import "TilePackage"
import "singletons" as Singletons
//------------------------------------------------------------------------------

Item {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: browseOrganizationTpksView

    property Portal portal
    property bool busy: false
    property double gridMargin: Singletons.Config.availableServicesView.gridMargin
    property var currentTileService: null
    property int thumbnailWidth: Singletons.Config.thumbnails.width
    property int thumbnailHeight: Singletons.Config.thumbnails.height
    property string searchQuery: Singletons.Config.browseOrgViewSearchQuery
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
        mainView.appToolBar.settingsButtonEnabled = true;
        mainView.appToolBar.backButtonEnabled = true;
        mainView.appToolBar.backButtonVisible = true;
        mainView.appToolBar.toolBarTitleLabel = Singletons.Strings.browseOrgTilePackages
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
            color: Singletons.Colors.subtleBackground
            opacity: .8
            z: 1000
            Accessible.role: Accessible.Pane

            Item{
                width: sf(80)
                height: sf(80)
                anchors.centerIn: parent
                Accessible.role: Accessible.Pane

                IconFont {
                    id: refreshSpinner
                    anchors.centerIn: parent
                    icon: _icons.spinner2
                    iconSizeMultiplier: 3
                    color: "#888"
                    Accessible.role: Accessible.Animation
                    Accessible.name: Singletons.Strings.animatedSpinner
                    Accessible.description: Singletons.Strings.animatedSpinnerDesc
                }
            }
        }

        GridView {
            id: servicesGridView
            anchors.fill: parent
            clip: true
            flow: GridView.FlowLeftToRight
            cellHeight: _returnCellWidth() + sf(30)
            cellWidth: _returnCellWidth()
            model: servicesListModel
            delegate: tileServiceDelegate
            highlight: highlight
            highlightFollowsCurrentItem: false
            currentIndex: -1
            z: 999
        }

        Rectangle {
            id: noServicesMessage
            anchors.fill: parent
            visible: false
            color: "#fff"
            z: servicesGridView.z + 1
            Text {
                anchors.centerIn: parent
                text: Singletons.Strings.noOrgTileServices
                font.family: defaultFontFamily
                font.weight: Font.Bold
                font.pointSize: Singletons.Config.largeFontSizePoint
                color: Singletons.Colors.boldUIElementFontColor
            }
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
                opacity: 1

                MouseArea {
                    id: tileClick
                    anchors.fill: parent
                    enabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: {
                        if (mouse.button == Qt.RightButton){
                            servicesGridView.currentIndex = index;
                            var p = servicesGridView.mapFromItem(tileContainer, mouse.x, mouse.y);
                            contextMenu.x = p.x;
                            contextMenu.y = p.y + servicesGridView.y;
                            contextMenu.open();
                        }
                        else {
                           servicesGridView.currentIndex = index;
                        }
                    }
                    onDoubleClicked: {
                        // ISSUE #94
                        // for some reason if you have this empty signal then double click
                        // seems to be ignored, which is what we want for this as it loads
                        // a new view. Without this empty signal, then the view is loaded twice.
                    }

                    Accessible.role: Accessible.Button
                    Accessible.name: Singletons.Strings.selectTileService
                    Accessible.description: Singletons.Strings.selectTileServiceDesc
                    Accessible.focusable: true
                    Accessible.onPressAction: {
                        if(enabled && visible){
                            clicked(null);
                        }
                    }
                }

                Item {
                    id: tileContent
                    anchors.fill: parent
                    anchors.margins: gridMargin / 2
                    Accessible.role: Accessible.Pane

                    Rectangle {
                        id: innerTile
                        anchors.fill: parent
                        Accessible.role: Accessible.Pane
                        color: Singletons.Colors.subtleBackground

                        ColumnLayout {
                            spacing: 1
                            anchors.fill: parent
                            anchors.margins: sf(1)

                            Item {
                                Layout.preferredWidth: parent.width
                                Layout.preferredHeight: (parent.width / thumbnailWidth * thumbnailHeight)

                                Image {
                                    anchors.fill: parent
                                    fillMode: Image.PreserveAspectFit
                                    sourceSize.width: thumbnailWidth
                                    sourceSize.height: thumbnailHeight

                                    source: (function () {
                                        var tn = "images/no_thumbnail.png";
                                        if (thumbnail !== null && thumbnail !== undefined && thumbnail !== "") {
                                            tn = browseOrganizationTpksView.portal.restUrl + "/content/items/" + id + "/info/" + thumbnail + (browseOrganizationTpksView.portal.signedIn ? "?token=" + browseOrganizationTpksView.portal.token : "");
                                        }
                                        return tn;
                                    })(thumbnail)

                                    onStatusChanged: {
                                        if (status === Image.Error){
                                            source = "images/no_thumbnail.png";
                                        }
                                    }

                                    Accessible.role: Accessible.Graphic
                                    Accessible.name: Singletons.Strings.tileServiceThumbnailDesc
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "#fafafa"
                                Accessible.role: Accessible.Pane

                                Text {
                                    text: title
                                    anchors.fill: parent
                                    anchors.margins: sf(10)
                                    font {
                                        pointSize: Singletons.Config.smallFontSizePoint
                                        family: defaultFontFamily
                                    }
                                    color: Singletons.Colors.boldUIElementFontColor
                                    verticalAlignment: Text.AlignVCenter
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                    Accessible.role: Accessible.StaticText
                                    Accessible.name: title
                                    Accessible.description: Singletons.Strings.tileServiceTitleDesc
                                }
                            }

                            Rectangle {
                                id: tileMenu
                                color: Singletons.Colors.subtleBackground
                                Layout.preferredHeight: 30  * AppFramework.displayScaleFactor
                                Layout.fillWidth: true
                                Accessible.role: Accessible.Pane

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 1

                                    Rectangle {
                                        id: tileWebMercIndicatorContainer
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Accessible.role: Accessible.Pane
                                        color: "#fafafa"

                                        Text {
                                            id: tileWebMercIndicator
                                            anchors.fill: parent
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignHCenter
                                            font.pointSize: Singletons.Config.xSmallFontSizePoint
                                            font.family: defaultFontFamily
                                            text: spatialReference
                                            color: isWebMercator ? "#007ac2" : "red"
                                            elide: Text.ElideRight

                                            Accessible.role: Accessible.StaticText
                                            Accessible.name: text
                                            Accessible.description: Singletons.Strings.spatialReferenceDesc
                                        }
                                    }

                                    Rectangle {
                                        id: tileProviderTypeContainer
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Accessible.role: Accessible.Pane
                                        color: "#fafafa"

                                        Text {
                                            id: tileProviderType
                                            anchors.fill: parent
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignHCenter
                                            font.pointSize: Singletons.Config.xSmallFontSizePoint
                                            font.family: defaultFontFamily
                                            text: owner === "esri" ? "Esri" : "Non-Esri"
                                            color: owner === "esri" ? "#007ac2" : "darkorange"

                                            Accessible.role: Accessible.StaticText
                                            Accessible.name: text
                                            Accessible.description: Singletons.Strings.tileServiceSourceDesc
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    Menu {
        id: contextMenu
        width: sf(200)
        padding: sf(1)

        property int menuItemHeight: sf(35)
        property var currentInfo: servicesListModel.get(servicesGridView.currentIndex)

        background: Rectangle {
            color: "#fff"
            border {
                width: sf(1)
                color: Singletons.Colors.subtleBackground
            }
        }

        Button {
            height: contextMenu.menuItemHeight
            width: parent.width
            background: Rectangle {
                color: parent.hovered ? Singletons.Colors.subtleBackground : "#fff"
            }
            contentItem: Text {
                anchors.fill: parent
                anchors.leftMargin: sf(10)
                text: Singletons.Strings.viewMetadata
                color: Singletons.Colors.boldUIElementFontColor
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: {
                metadataTextArea.clear();
                for (var metadata in contextMenu.currentInfo) {
                    if (contextMenu.currentInfo[metadata]!== undefined ) {
                        metadataTextArea.append("<h2>" + metadata + "</h2>");
                        if (typeof contextMenu.currentInfo[metadata] !== "object") {
                            metadataTextArea.append("<p>" + JSON.stringify(contextMenu.currentInfo[metadata]) + "</p>");
                        }
                        else {
                            var subdata = contextMenu.currentInfo[metadata].get(0);
                            if (subdata !== undefined) {
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
            Accessible.description: Singletons.Strings.viewMetadataDesc
        }

        Rectangle {
            height: sf(1)
            width: parent.width
            color: Singletons.Colors.subtleBackground
        }

        Button {
            height: visible ? contextMenu.menuItemHeight : 0
            width: parent.width
            background: Rectangle {
                color: parent.hovered ? Singletons.Colors.subtleBackground : "#fff"
            }
            contentItem: Text {
                anchors.fill: parent
                anchors.leftMargin: sf(10)
                text: qsTr("Download via Web Browser")
                color: Singletons.Colors.boldUIElementFontColor
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: {
                var baseUrl = !portal.isPortal ? "http://www.arcgis.com/sharing/rest/content" : portal.restUrl + "/content";
                Qt.openUrlExternally( baseUrl + "/items/" + contextMenu.currentInfo.id + "/data?token="+ portal.token);
            }
            Accessible.role: Accessible.MenuItem
            Accessible.name: text
            Accessible.description: Singletons.Strings.viewOnArcgisOrPortalDesc
        }

        Rectangle {
            height: sf(1)
            width: parent.width
            color: Singletons.Colors.subtleBackground
        }

        Button {
            height: visible ? contextMenu.menuItemHeight : 0
            width: parent.width
            background: Rectangle {
                color: parent.hovered ? Singletons.Colors.subtleBackground : "#fff"
            }
            contentItem: Text {
                anchors.fill: parent
                anchors.leftMargin: sf(10)
                text: !portal.isPortal ? Singletons.Strings.viewOnArcgis : Singletons.Strings.viewOnPortal
                color: Singletons.Colors.boldUIElementFontColor
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: {
                var baseUrl = !portal.isPortal ? "http://www.arcgis.com/home" : portal.portalUrl + "/home";
                Qt.openUrlExternally( baseUrl + "/item.html?id=" + contextMenu.currentInfo.id + "&token="+ browseOrganizationTpksView.portal.token);
            }
            Accessible.role: Accessible.MenuItem
            Accessible.name: text
            Accessible.description: Singletons.Strings.viewOnArcgisOrPortalDesc
        }

        Accessible.role: Accessible.PopupMenu
        Accessible.name: Singletons.Strings.contextMenuDesc
    }

    //--------------------------------------------------------------------------

    Dialog {
        id: metadataDialog
        visible: false
        title: Singletons.Strings.metadata
        modality: Qt.ApplicationModal

        Accessible.role: Accessible.Dialog
        Accessible.name: title
        Accessible.description: Singletons.Strings.metadataDialogDesc

        contentItem: Rectangle {
            color: Singletons.Colors.subtleBackground
            anchors.fill: parent
            width: app.width - sf(30)
            height: app.height - sf(30)
            implicitWidth: app.width - sf(30)
            implicitHeight: app.height - sf(30)
            Flickable {
                id: view
                anchors.fill: parent
                contentHeight: metadataTextArea.height
                clip: true
                flickableDirection: Flickable.VerticalFlick
                TextArea {
                    id: metadataTextArea
                    width: parent.width
                    text: ""
                    color: app.info.properties.toolBarBackgroundColor
                    font.family: defaultFontFamily
                    readOnly: true
                    textFormat: Text.RichText
                    wrapMode: TextArea.Wrap
                    onLinkActivated: {
                        Qt.openUrlExternally(link);
                    }

                    Accessible.role: Accessible.StaticText
                    Accessible.name: Singletons.Strings.metatdataTextDesc
                    Accessible.multiLine: true
                    Accessible.readOnly: true
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: highlight

        Item {
            width: servicesGridView.cellWidth
            height: servicesGridView.cellHeight
            x: servicesGridView.currentItem.x
            y: servicesGridView.currentItem.y
            z: 1000
            Accessible.ignored: true

            Rectangle {
                color: "transparent"
                anchors.fill: parent
                anchors.margins: gridMargin / 2
                visible: true
                border.width: sf(1)
                border.color: Singletons.Config.availableServicesView.highlightColor
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
                try {
//                    console.log(JSON.stringify(result));
                    if (!result.description) {
                        result.description = "";
                    }

//                    console.log(result.thumbnail);

                    if (!result.hasOwnProperty("thumbnail")) {
                        result["thumbnail"] = "";
                    }

                    result.isWebMercator = _isWebMercator(result.spatialReference);

                    servicesListModel.append(result);
                }
                catch (error) {
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

                if ( !(servicesListModel.count > 0) ){
                    noServicesMessage.visible = true;
                }
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

        if (app.width < sf(400)) {
            width = app.width;
        }

        if (app.width >= sf(400) && app.width < sf(600)) {
            width = app.width / 2;
        }

        if (app.width >= sf(600) && app.width < sf(900)) {
            width = app.width / 3;
        }

        if (app.width >= sf(900) && app.width < sf(1200)) {
            width = app.width / 4;
        }

        if (app.width >= sf(1200)) {
            width = app.width / 5;
        }

        return width;
    }

    //--------------------------------------------------------------------------

    function _buttonStates(control) {

        if (control.pressed) {
            return app.info.properties.mainButtonPressedColor;
        }
        else if (!control.enabled) {
            return "#888";
        }
        else {
            return app.info.properties.mainButtonBackgroundColor;
        }

    }

    //--------------------------------------------------------------------------

    function _exportTilesAllowed(serviceInfo) {

        if (serviceInfo.hasOwnProperty("exportTilesAllowed")) {
            if (serviceInfo.exportTilesAllowed === false) {
                return false;
            }
            else {
                return true;
            }
        }
        else {
            return false;
        }

    }

    //--------------------------------------------------------------------------

    function _isWebMercator(sr){

        // This needs to be replaced with the better logic from TilePackageUpload
        // See #135

        if ( sr === Singletons.Constants.kWebMercSR || sr === Singletons.Constants.kWebMercLatestWKID.toString() || sr === Singletons.Constants.kWebMercWKID.toString() ){
            return true;
        }
        else{
            return false;
        }
    }

    // END /////////////////////////////////////////////////////////////////////
}
