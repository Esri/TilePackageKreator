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

import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
//--------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
//--------------------------------------------------------------------------
import "Portal"
import "TilePackage"
//--------------------------------------------------------------------------

Item {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: availableServicesView

    property Portal portal
    property Config config

    property AvailableServicesModel asm: AvailableServicesModel {
        portal: availableServicesView.portal
        onModelComplete: {
            if(asm.servicesListModel.count > 0){
                servicesGridView.currentIndex = -1;
                servicesGridView.interactive = true;
                servicesGridView.enabled = true;
                if (activityIndicator.visible === true) {
                    activityIndicator.visible = false;
                }
            }
            else{
                refreshSpinner.visible = false;
                servicesStatusText.text = qsTr("No export tile services are available.");
            }
            rotator.stop();
        }
        onServicesCountReady: {
            servicesStatusText.text = "Found %1 total services. Querying each for export tile ability.".arg(numberOfServices);
        }
        onFailed:{
            try{
                throw new Error(error);
            }
            catch(e){
                appMetrics.reportError(e)
            }
        }
        onServiceAdded: {
            addServiceEntry.visible = false;
            addServiceEntry.enabled = false;
        }
        onServiceNotAdded: {
            addServiceEntry.visible = false;
            addServiceEntry.enabled = false;
            viewStatusIndicator.messageType = viewStatusIndicator.error
            viewStatusIndicator.message = "The service wasn't added. There may be a problem with the service or url entered.";
            viewStatusIndicator.show();
        }
    }

    property double gridMargin: config.availableServicesView.gridMargin * AppFramework.displayScaleFactor
    property var currentTileService: null
    property int thumbnailWidth: config.thumbnails.width
    property int thumbnailHeight: config.thumbnails.height

    // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////////

    Component.onCompleted: {
        asm.getAvailableServices.start();
        activityIndicator.visible = true;
        rotator.target = refreshSpinner;
        refreshSpinner.visible = true;
        rotator.start();
    }

    //--------------------------------------------------------------------------

    Stack.onStatusChanged: {
        if(Stack.status === Stack.Deactivating){
            mainView.appToolBar.toolBarTitleLabel = "";
        }
        if(Stack.status === Stack.Activating){
            mainView.appToolBar.enabled = true
            mainView.appToolBar.backButtonEnabled = (!calledFromAnotherApp) ? true : false;
            mainView.appToolBar.backButtonVisible = (!calledFromAnotherApp) ? true : false;
            mainView.appToolBar.historyButtonEnabled = true;
            mainView.appToolBar.toolBarTitleLabel = qsTr("Create New Tile Package")
        }
    }

    // UI //////////////////////////////////////////////////////////////////////

    Rectangle {
        id: servicesGrid
        color: "white"
        anchors.fill: parent
        Accessible.role: Accessible.Pane

        //----------------------------------------------------------------------

        Rectangle {
            id: activityIndicator
            anchors.fill: parent
            visible: false
            color: config.subtleBackground
            opacity: .8
            z: 1000
            Accessible.role: Accessible.Pane

            ColumnLayout{
                spacing: 0
                anchors.fill: parent

                Rectangle{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Accessible.ignored: true

                    Rectangle{
                        width: 80 * AppFramework.displayScaleFactor
                        height: 80 * AppFramework.displayScaleFactor
                        anchors.centerIn: parent
                        color: "transparent"

                        Accessible.role: Accessible.Pane

                        Text{
                            id: refreshSpinner
                            anchors.centerIn: parent
                            font.pointSize: config.largeFontSizePoint * 3
                            color: "#888"
                            font.family: icons.name
                            text: icons.spinner2

                            Accessible.role: Accessible.Animation
                            Accessible.name: qsTr("animated spinner")
                            Accessible.description: qsTr("This is an animated spinner that appears when network queries are in progress.")
                        }
                    }
                }

                Rectangle{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Accessible.role: Accessible.Pane

                    Text{
                        anchors.fill: parent
                        id: servicesStatusText
                        font.family: notoRegular.name
                        font.pointSize: config.largeFontSizePoint
                        text: qsTr("Querying Services. Please wait.")
                        verticalAlignment: Text.AlignTop
                        horizontalAlignment: Text.AlignHCenter

                        Accessible.role: Accessible.AlertMessage
                        Accessible.name: text
                        Accessible.description: qsTr("This status text will update as services are discovered and then queried for the ability to export tiles.")
                    }
                }
            }
        }

        //----------------------------------------------------------------------

        Rectangle {
            id: servicesGridViewLabel
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.left: parent.left
            height: 60  * AppFramework.displayScaleFactor
            color: config.subtleBackground
            Accessible.role: Accessible.Pane

            RowLayout{
                anchors.fill: parent
                spacing: 0

                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: config.subtleBackground
                    visible: !addServiceEntry.visible
                    enabled: !addServiceEntry.visible
                    Accessible.role: Accessible.Pane

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 20 * AppFramework.displayScaleFactor
                        verticalAlignment: Text.AlignVCenter
                        text: qsTr("Select tile service to be used as the source for the tile package")
                        font.family: notoRegular.name

                        Accessible.role: Accessible.Heading
                        Accessible.name: text
                    }
                }

                Rectangle{
                    Layout.fillHeight: true
                    Layout.preferredWidth: 180 * AppFramework.displayScaleFactor
                    Layout.margins: 8 * AppFramework.displayScaleFactor
                    color: config.subtleBackground
                    visible: !addServiceEntry.visible
                    enabled: !addServiceEntry.visible
                    Accessible.role: Accessible.Pane

                    Button{
                        anchors.fill: parent

                        style: ButtonStyle {
                            background: Rectangle {
                                anchors.fill: parent
                                color: config.buttonStates(control)
                                radius: app.info.properties.mainButtonRadius
                                border.width: (control.enabled) ? app.info.properties.mainButtonBorderWidth : 0
                                border.color: app.info.properties.mainButtonBorderColor
                            }
                        }

                        RowLayout{
                            anchors.fill: parent
                            spacing: 0

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.height
                                color: "transparent"
                                Accessible.role: Accessible.Pane

                                Text{
                                    anchors.centerIn: parent
                                    font.pointSize: config.largeFontSizePoint * .8
                                    color: app.info.properties.mainButtonFontColor
                                    font.family: icons.name
                                    text: icons.plus_sign
                                    Accessible.ignored: true
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "transparent"
                                Accessible.role: Accessible.Pane

                                Text {
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignLeft
                                    verticalAlignment: Text.AlignVCenter
                                    color: app.info.properties.mainButtonFontColor
                                    textFormat: Text.RichText
                                    text: qsTr("Add Tile Service")
                                    font.pointSize: config.baseFontSizePoint
                                    font.family: notoRegular.name
                                }
                            }
                        }

                        onClicked: {
                            addServiceEntry.visible = true;
                            addServiceEntry.enabled = true;
                          }
                    }
                }

                Rectangle{
                    id: addServiceEntry
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: config.subtleBackground
                    visible: false
                    enabled: false
                    Accessible.role: Accessible.Pane

                    RowLayout{
                        anchors.fill: parent
                        anchors.margins: 5 * AppFramework.displayScaleFactor
                        spacing: 5 * AppFramework.displayScaleFactor

                        TextField {
                            id: tileServiceTextField
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            placeholderText: qsTr("Enter url (e.g. http://someservice.gov/arcgis/rest/services/example/MapServer)")

                            style: TextFieldStyle {
                                background: Rectangle {
                                    anchors.fill: parent
                                    border.width: config.formElementBorderWidth
                                    border.color: config.formElementBorderColor
                                    radius: config.formElementRadius
                                    color: _uiEntryElementStates(control)
                                }
                                textColor: config.formElementFontColor
                                font.family: notoRegular.name
                            }

                            validator: RegExpValidator{
                                regExp: /(http(s)*:\/\/).*/g
                            }

                            Accessible.role: Accessible.EditableText
                            Accessible.name: qsTr("Enter a title for the exported tile package.")
                            Accessible.focusable: true
                        }

                        Button{
                            Layout.fillHeight: true
                            Layout.preferredWidth: 70 * AppFramework.displayScaleFactor
                            enabled: tileServiceTextField.length > 0 && tileServiceTextField.acceptableInput

                            property string buttonText: qsTr("Add")

                            style: ButtonStyle {
                                background: Rectangle {
                                    anchors.fill: parent
                                    color: config.buttonStates(control)
                                    radius: app.info.properties.mainButtonRadius
                                    border.width: (control.enabled) ? app.info.properties.mainButtonBorderWidth : 0
                                    border.color: app.info.properties.mainButtonBorderColor
                                }
                            }
                            Text {
                                color: app.info.properties.mainButtonFontColor
                                anchors.centerIn: parent
                                textFormat: Text.RichText
                                text: parent.buttonText
                                font.pointSize: config.baseFontSizePoint
                                font.family: notoRegular.name
                            }

                            onClicked: {
                               addServiceEntry.enabled = false;
                               asm.addService(tileServiceTextField.text);
                               tileServiceTextField.text = "";
                            }
                        }

                        Button{
                            Layout.fillHeight: true
                            Layout.preferredWidth: 70 * AppFramework.displayScaleFactor

                            property string buttonText: qsTr("Cancel")

                            style: ButtonStyle {
                                background: Rectangle {
                                    anchors.fill: parent
                                    color: config.buttonStates(control, "clear")
                                    radius: app.info.properties.mainButtonRadius
                                    border.width: (control.enabled) ? app.info.properties.mainButtonBorderWidth : 0
                                    border.color: "#fff"
                                }
                            }

                            Text {
                                color: app.info.properties.mainButtonBackgroundColor
                                anchors.centerIn: parent
                                textFormat: Text.RichText
                                text: parent.buttonText
                                font.pointSize: config.baseFontSizePoint
                                font.family: notoRegular.name
                            }

                            onClicked: {
                               addServiceEntry.enabled = false;
                               addServiceEntry.visible = false;
                               tileServiceTextField.text = "";
                            }
                        }
                    }
                }
            }
        }

        //----------------------------------------------------------------------

        GridView {
            id: servicesGridView
            anchors.top: servicesGridViewLabel.bottom
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            enabled: false
            clip: true
            flow: GridView.FlowLeftToRight
            cellHeight: _returnCellWidth()
            cellWidth: _returnCellWidth()
            model: asm.servicesListModel
            delegate: tileServiceDelegate
            highlight: highlight
            highlightFollowsCurrentItem: false
            interactive: false
            currentIndex: -1
            z: 999

            onCurrentIndexChanged: {
                currentTileService = currentIndex >= 0 ? asm.servicesListModel.get(currentIndex) : null;
            }

        }

        //----------------------------------------------------------------------

        Rectangle{
            id: viewStatusIndicatorContainer
            width: parent.width
            height: 50 * AppFramework.displayScaleFactor
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            z: 100000
            visible: false
            Accessible.role: Accessible.Pane

            StatusIndicator{
                id: viewStatusIndicator
                anchors.fill: parent
                containerHeight: parent.height
                hideAutomatically: false
                showDismissButton: true
                statusTextFontSize: config.baseFontSizePoint

                onShow: {
                    viewStatusIndicatorContainer.visible = true;
                }
                onHide: {
                    viewStatusIndicatorContainer.visible = false;
                }

                Accessible.role: Accessible.AlertMessage
                Accessible.name: message
                Accessible.description: qsTr("This alert message provides information about where .pitem files are saved, or if there was an error.")
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
                    onClicked: {
                       servicesGridView.currentIndex = index;
                       mainStackView.push({
                           item: etv,
                           properties: {
                               currentTileService: currentTileService
                           }
                       });
                    }
                    onDoubleClicked: {
                        // ISSUE #94
                        // for some reason if you have this empty signal then double click
                        // seems to be ignored, which is what we want for this as it loads
                        // a new view. Without this empty signal, then the view is loaded twice.
                    }

                    Accessible.role: Accessible.Button
                    Accessible.name: qsTr("Select this tile service to export from.")
                    Accessible.description: qsTr("This clickable mouse area will select the %1 tile service to export tiles from and will transition to the export area and details selection view.".arg(title))
                    Accessible.focusable: true
                    Accessible.onPressAction: {
                        if(enabled && visible){
                            clicked(null);
                        }
                    }

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
                        anchors.margins: gridMargin / 2 + 5
                        Accessible.role: Accessible.Pane

                        ColumnLayout {
                            spacing: 0
                            anchors.fill: parent

                            Image {
                                Layout.preferredWidth: innerTile.width
                                Layout.preferredHeight: (innerTile.width / thumbnailWidth * thumbnailHeight)
                                fillMode: Image.PreserveAspectFit
                                source: (function () {
                                    var tn = "images/no_thumbnail.png";
                                    if (thumbnail !== null && thumbnail !== undefined && thumbnail !== "") {
                                        tn = availableServicesView.portal.restUrl + "/content/items/" + id + "/info/" + thumbnail + (availableServicesView.portal.signedIn ? "?token=" + availableServicesView.portal.token : "");
                                    }
                                    return tn;
                                })(thumbnail)

                                Accessible.role: Accessible.Graphic
                                Accessible.name: qsTr("Tile service thumbnail image.")
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
                                        family: notoRegular.name
                                    }
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                    Accessible.role: Accessible.StaticText
                                    Accessible.name: title
                                    Accessible.description: qsTr("Title of the tile service.")
                                }
                            }

                            Rectangle {
                                id: tileMenu
                                color: "white"
                                Layout.preferredHeight: 30  * AppFramework.displayScaleFactor
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
                                            anchors.leftMargin: 10 * AppFramework.displayScaleFactor
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignLeft
                                            font.pointSize: config.xSmallFontSizePoint
                                            font.family: notoRegular.name
                                            text: isWebMercator  ? "Web Mercator" : "NOT Web Mercator"
                                            color: isWebMercator ? "#007ac2" : "red"

                                            Accessible.role: Accessible.StaticText
                                            Accessible.name: text
                                            Accessible.description: qsTr("This text denotes whether the tile service is or is not web mercator spatial reference.")
                                        }
                                    }

                                    Rectangle {
                                        id: tileProviderTypeContainer
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        Accessible.role: Accessible.Pane

                                        Text {
                                            id: tileProviderType
                                            anchors.centerIn: parent
                                            font.pointSize: config.xSmallFontSizePoint
                                            font.family: notoRegular.name
                                            text: owner === "esri" ? "Esri" : "Non-Esri"
                                            color: owner === "esri" ? "#007ac2" : "darkorange"

                                            Accessible.role: Accessible.StaticText
                                            Accessible.name: text
                                            Accessible.description: qsTr("This text denotes whether the tile service is from an Esri source or an external source.")
                                        }
                                    }

                                    Button {
                                        id: tileMenuBtn
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: parent.height

                                        style: ButtonStyle {
                                            background: Rectangle {
                                                anchors.fill: parent
                                                color: "white"
                                                radius: 0
                                                Image {
                                                    id: tileMenuBtnIcon
                                                    source: "images/menu.png"
                                                    width: 20
                                                    height: 20
                                                    anchors.centerIn: parent
                                                    Accessible.ignored: true
                                                }
                                                ColorOverlay {
                                                    anchors.fill: tileMenuBtnIcon
                                                    source: tileMenuBtnIcon
                                                    color: control.hovered ? app.info.properties.mainButtonBackgroundColor : "#ccc"
                                                    Accessible.ignored: true
                                                }
                                            }
                                        }
                                        onClicked: {
                                            tileMenuMenu.popup();
                                        }

                                        Accessible.role: Accessible.Button
                                        Accessible.name: qsTr("Tile Service Context Menu")
                                        Accessible.description: qsTr("This button opens up a context menu with options related to this tile service.")
                                    }
                                }
                            }

                            Menu {
                                id: tileMenuMenu
                                property int tileIndex: index

                                MenuItem {
                                    text: qsTr("View Metadata")

                                    onTriggered: {
                                        metadataTextArea.append("<h2>Description</h2>");
                                        metadataTextArea.append(asm.servicesListModel.get(tileMenuMenu.tileIndex).description);
                                        metadataTextArea.append("<p>&nbsp;</p>");
                                        metadataTextArea.append("<h2>Spatial Reference</h2>");
                                        metadataTextArea.append(asm.servicesListModel.get(tileMenuMenu.tileIndex).spatialReference);
                                        metadataTextArea.append("<p>&nbsp;</p>");
                                        metadataTextArea.append("<h2>Modified</h2>");
                                        metadataTextArea.append(new Date(asm.servicesListModel.get(tileMenuMenu.tileIndex).modified).toDateString());
                                        metadataTextArea.append("<p>&nbsp;</p>");
                                        metadataTextArea.append("<h2>Owner</h2>");
                                        metadataTextArea.append(asm.servicesListModel.get(tileMenuMenu.tileIndex).owner);
                                        metadataTextArea.append("<p>&nbsp;</p>");
                                        metadataTextArea.append("<h2>License Information</h2>");
                                        metadataTextArea.append(asm.servicesListModel.get(tileMenuMenu.tileIndex).licenseInfo);
                                        metadataTitle.text = asm.servicesListModel.get(tileMenuMenu.tileIndex).title;
                                        metadataTextArea.cursorPosition = 0;
                                        metadataDialog.open();
                                    }

                                    Accessible.role: Accessible.MenuItem
                                    Accessible.name: text
                                    Accessible.description: qsTr("This menu item will open up a dialog window and display metadata associated with this tile service.")
                                }

                                MenuItem {
                                    text: !portal.isPortal ? qsTr("View on ArcGIS") : qsTr("View on Portal")
                                    visible: isArcgisTileService || portal.isPortal
                                    enabled: isArcgisTileService || portal.isPortal
                                    onTriggered: {
                                        var baseUrl = !portal.isPortal ? "http://www.arcgis.com/home" : portal.portalUrl + "/home";
                                        Qt.openUrlExternally( baseUrl + "/item.html?id=" + asm.servicesListModel.get(tileMenuMenu.tileIndex).id + "&token="+ availableServicesView.portal.token);
                                        //Qt.openUrlExternally("http://www.arcgis.com/home/item.html?id=" + asm.servicesListModel.get(tileMenuMenu.tileIndex).id + "&token=" + availableServicesView.portal.token);
                                    }
                                    Accessible.role: Accessible.MenuItem
                                    Accessible.name: text
                                    Accessible.description: qsTr("This menu item will open up a web browser and load the ArcGIS or Portal item for this tile service.")
                                }

                                MenuItem {
                                    text: isArcgisTileService ? qsTr("View REST Service") : qsTr("View Service")
                                    onTriggered: {
                                        var thisTile = asm.servicesListModel.get(tileMenuMenu.tileIndex);
                                        var tileUrl = (thisTile.url).toString();

                                        if (thisTile.isArcgisTileService === true) {
                                            if(thisTile.useTokenToAccess){
                                                Qt.openUrlExternally(tileUrl + (availableServicesView.portal.signedIn ? "?token=" + availableServicesView.portal.token : ""));
                                            }
                                            else{
                                                Qt.openUrlExternally(tileUrl);
                                            }
                                        } else {
                                            Qt.openUrlExternally(tileUrl);
                                        }
                                    }
                                    Accessible.role: Accessible.MenuItem
                                    Accessible.name: text
                                    Accessible.description: qsTr("This menu item will open up a web browser and load the ArcGIS or Portal REST service view of this tile service.")
                                }

                                MenuItem {
                                    text: qsTr("Create .pitem")
                                    onTriggered: {
                                        tpkPItem.create(asm.servicesListModel.get(tileMenuMenu.tileIndex));
                                    }
                                    Accessible.role: Accessible.MenuItem
                                    Accessible.name: text
                                    Accessible.description: qsTr("This menu item will open up a file dialog and save a pitem file to the location specified in the dialog.")
                                }

                            }
                        }
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
            width: servicesGridView.cellWidth
            height: servicesGridView.cellHeight
            x: servicesGridView.currentItem.x
            y: servicesGridView.currentItem.y
            z: 1000
            Accessible.ignored: true

            Rectangle {
                id: highlightRect
                color: "transparent"
                anchors.fill: parent
                anchors.margins: gridMargin / 2
                visible: true
                border.width: 1 * AppFramework.displayScaleFactor
                border.color: config.availableServicesView.highlightColor
            }

            Rectangle {
                width: servicesGridView.cellWidth / 6
                height: servicesGridView.cellWidth / 6
                radius: (servicesGridView.cellWidth / 6) / 2
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 15 * AppFramework.displayScaleFactor
                anchors.leftMargin: 15 * AppFramework.displayScaleFactor
                Image {
                    id: tileSelectedIcon
                    source: "images/checkmark_inverted.png"
                    width: parent.width - 2
                    height: parent.width - 2
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
            width: availableServicesView.parent.width - 10
            height: availableServicesView.parent.height - 10
            implicitWidth: availableServicesView.parent.width - 10
            implicitHeight: availableServicesView.parent.height - 10

            ColumnLayout {
                spacing: 1
                anchors.fill: parent

                Rectangle {
                    Layout.preferredHeight: 60
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
                            font.family: notoRegular.name

                            Accessible.role: Accessible.Heading
                            Accessible.name: text
                        }

                        Button {
                            id: closeBtn
                            Layout.preferredWidth: 60 * AppFramework.displayScaleFactor
                            Layout.fillHeight: true
                            style: ButtonStyle {
                                background: Rectangle {
                                    anchors.fill: parent
                                    color: "white"
                                    radius: 0

                                    Image {
                                        id: closeBtnIcon
                                        source: "images/process_failed.png"
                                        width: parent.width - 40
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
                        anchors.margins: 10  * AppFramework.displayScaleFactor
                        text: ""
                        textColor: app.info.properties.toolBarBackgroundColor
                        font.family: notoRegular.name
                        readOnly: true
                        frameVisible: false
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

    TilePackagePItem{
        id: tpkPItem

        onSuccess: {
            viewStatusIndicator.messageType = viewStatusIndicator.success
            viewStatusIndicator.message = "File saved to %1".arg(path);
            viewStatusIndicator.show();
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

        return width;
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

    // END /////////////////////////////////////////////////////////////////////

}
