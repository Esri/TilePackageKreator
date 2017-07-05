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

import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
//--------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
//--------------------------------------------------------------------------
import "Portal"
import "TilePackage"
import "singletons" as Singletons
//--------------------------------------------------------------------------

Item {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: availableServicesView

    property Portal portal

    property AvailableServicesModel asm: AvailableServicesModel {
        portal: availableServicesView.portal

        onModelComplete: {
            if (asm.servicesListModel.count > 0) {
                servicesGridView.currentIndex = -1;
                servicesGridView.interactive = true;
                servicesGridView.enabled = true;
            }
            else {
                refreshSpinner.visible = false;
                noServicesMessage.visible = true;
            }

            if (activityIndicator.visible) {
                activityIndicator.visible = false;
            }
            rotator.stop();
        }

        onServicesCountReady: {
            servicesStatusText.text = Singletons.Strings.foundXTotalServices.arg(numberOfServices);
        }

        onFailed: {
            try {
                throw new Error(error);
            }
            catch(e) {
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
            viewStatusIndicator.message = Singletons.Strings.serviceNotAddedError
            viewStatusIndicator.show();
        }
    }

    property double gridMargin: Singletons.Config.availableServicesView.gridMargin * AppFramework.displayScaleFactor
    property var currentTileService: null
    property int thumbnailWidth: Singletons.Config.thumbnails.width
    property int thumbnailHeight: Singletons.Config.thumbnails.height

    // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////////

    Component.onCompleted: {
        asm.getAvailableServices.start();
        activityIndicator.visible = true;
        rotator.target = refreshSpinner;
        refreshSpinner.visible = true;
        rotator.start();
    }

    //--------------------------------------------------------------------------

    StackView.onActivating: {
        mainView.appToolBar.enabled = true
        mainView.appToolBar.backButtonEnabled = (!calledFromAnotherApp) ? true : false;
        mainView.appToolBar.backButtonVisible = (!calledFromAnotherApp) ? true : false;
        mainView.appToolBar.historyButtonEnabled = true;
        mainView.appToolBar.toolBarTitleLabel = Singletons.Strings.createNewTilePackage
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
            color: Singletons.Config.subtleBackground
            opacity: .8
            z: 1000
            Accessible.role: Accessible.Pane

            ColumnLayout {
                spacing: 0
                anchors.fill: parent

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Accessible.ignored: true

                    Rectangle {
                        width: sf(80)
                        height: sf(80)
                        anchors.centerIn: parent
                        color: "transparent"

                        Accessible.role: Accessible.Pane

                        Text {
                            id: refreshSpinner
                            anchors.centerIn: parent
                            font.pointSize: Singletons.Config.largeFontSizePoint * 3
                            color: "#888"
                            font.family: iconFont
                            text: icons.spinner2

                            Accessible.role: Accessible.Animation
                            Accessible.name: Singletons.Strings.animatedSpinner
                            Accessible.description: Singletons.Strings.animatedSpinnerDesc
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Accessible.role: Accessible.Pane

                    Text {
                        anchors.fill: parent
                        id: servicesStatusText
                        font.family: notoRegular
                        font.pointSize: Singletons.Config.largeFontSizePoint
                        text: Singletons.Strings.queryingServices
                        verticalAlignment: Text.AlignTop
                        horizontalAlignment: Text.AlignHCenter

                        Accessible.role: Accessible.AlertMessage
                        Accessible.name: text
                        Accessible.description: Singletons.Strings.statusTextDesc
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
            height: sf(60)
            color: Singletons.Config.subtleBackground
            Accessible.role: Accessible.Pane

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: Singletons.Config.subtleBackground
                    visible: !addServiceEntry.visible
                    enabled: !addServiceEntry.visible
                    Accessible.role: Accessible.Pane

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: sf(20)
                        verticalAlignment: Text.AlignVCenter
                        text: Singletons.Strings.selectTileService
                        font.family: notoRegular

                        Accessible.role: Accessible.Heading
                        Accessible.name: text
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.height - sf(20)
                    Layout.margins: sf(10)
                    color: Singletons.Config.subtleBackground
                    visible: !addServiceEntry.visible
                    enabled: !addServiceEntry.visible
                    Accessible.role: Accessible.Pane

                    Button {
                        id: addTileServiceBtn
                        anchors.fill: parent

                        property string buttonText: Singletons.Strings.addTileService

                        ToolTip.visible: hovered
                        ToolTip.text: buttonText

                        background: Rectangle {
                            anchors.fill: parent
                            color: Singletons.Config.subtleBackground
                            radius: sf(3)
                            border.width: sf(1)
                            border.color: app.info.properties.mainButtonBorderColor
                         }

                        Text {
                            anchors.centerIn: parent
                            font.pointSize: Singletons.Config.largeFontSizePoint * .8
                            color: app.info.properties.mainButtonBackgroundColor
                            font.family: iconFont
                            text: icons.plus_sign
                            Accessible.ignored: true
                        }

                        onClicked: {
                            addServiceEntry.visible = true;
                            addServiceEntry.enabled = true;
                        }

                        Accessible.role: Accessible.Button
                        Accessible.name: buttonText
                        Accessible.description: Singletons.Strings.addTileServiceDesc
                        Accessible.onPressAction: {
                            if(enabled && visible){
                                clicked(null);
                            }
                        }
                    }
                }

                Rectangle {
                    id: addServiceEntry
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: Singletons.Config.subtleBackground
                    visible: false
                    enabled: false
                    Accessible.role: Accessible.Pane

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: sf(5)
                        spacing: sf(5)

                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            TextField {
                                id: tileServiceTextField
                                width: parent.width
                                height: parent.height
                                placeholderText: Singletons.Strings.tileServiceUrlExample

                                background: Rectangle {
                                    anchors.fill: parent
                                    border.width: Singletons.Config.formElementBorderWidth
                                    border.color: Singletons.Config.formElementBorderColor
                                    radius: Singletons.Config.formElementRadius
                                    color: _uiEntryElementStates(parent)
                                }
                                color: Singletons.Config.formElementFontColor
                                font.family: notoRegular

                                validator: RegExpValidator {
                                    regExp: /(http(s)*:\/\/).*/g
                                }

                                Accessible.role: Accessible.EditableText
                                Accessible.name: Singletons.Strings.enterUrlForTileService
                                Accessible.focusable: true
                            }
                        }

                        Button {
                            Layout.fillHeight: true
                            Layout.preferredWidth: sf(70)
                            enabled: tileServiceTextField.length > 0 && tileServiceTextField.acceptableInput

                            property string buttonText: Singletons.Strings.add

                            background: Rectangle {
                                anchors.fill: parent
                                color: Singletons.Config.buttonStates(parent)
                                radius: app.info.properties.mainButtonRadius
                                border.width: parent.enabled ? app.info.properties.mainButtonBorderWidth : 0
                                border.color: app.info.properties.mainButtonBorderColor
                            }

                            Text {
                                color: app.info.properties.mainButtonFontColor
                                anchors.centerIn: parent
                                textFormat: Text.RichText
                                text: parent.buttonText
                                font.pointSize: Singletons.Config.baseFontSizePoint
                                font.family: notoRegular
                                Accessible.ignored: true
                            }

                            onClicked: {
                               addServiceEntry.enabled = false;
                               asm.addService(tileServiceTextField.text);
                               tileServiceTextField.clear();
                            }

                            Accessible.role: Accessible.Button
                            Accessible.name: buttonText
                               Accessible.onPressAction: {
                                if(enabled && visible){
                                    clicked(null);
                                }
                            }
                        }

                        Button {
                            Layout.fillHeight: true
                            Layout.preferredWidth: sf(70)

                            property string buttonText: Singletons.Strings.cancel

                            background: Rectangle {
                                anchors.fill: parent
                                color: Singletons.Config.buttonStates(parent, "clear")
                                radius: app.info.properties.mainButtonRadius
                                border.width: parent.enabled ? app.info.properties.mainButtonBorderWidth : 0
                                border.color: "#fff"
                            }

                            Text {
                                color: app.info.properties.mainButtonBackgroundColor
                                anchors.centerIn: parent
                                textFormat: Text.RichText
                                text: parent.buttonText
                                font.pointSize: Singletons.Config.baseFontSizePoint
                                font.family: notoRegular
                                Accessible.ignored: true
                            }

                            onClicked: {
                               addServiceEntry.enabled = false;
                               addServiceEntry.visible = false;
                               tileServiceTextField.clear();
                            }

                            Accessible.role: Accessible.Button
                            Accessible.name: buttonText
                            Accessible.onPressAction: {
                                if(enabled && visible){
                                    clicked(null);
                                }
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
            cellHeight: _returnCellWidth() + sf(30)
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

        Rectangle {
            id: noServicesMessage
            anchors.top: servicesGridViewLabel.bottom
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            visible: false
            color: "#fff"
            Text {
                anchors.centerIn: parent
                text: Singletons.Strings.noTileServices
                font.family: notoBold
                font.pointSize: Singletons.Config.largeFontSizePoint
                color: Singletons.Config.boldUIElementFontColor
            }
        }

        //----------------------------------------------------------------------

        Rectangle {
            id: viewStatusIndicatorContainer
            width: parent.width
            height: sf(50)
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            z: 100000
            visible: false
            Accessible.role: Accessible.Pane

            StatusIndicator {
                id: viewStatusIndicator
                anchors.fill: parent
                containerHeight: parent.height
                hideAutomatically: false
                showDismissButton: true
                statusTextFontSize: Singletons.Config.baseFontSizePoint

                onShow: {
                    viewStatusIndicatorContainer.visible = true;
                }
                onHide: {
                    viewStatusIndicatorContainer.visible = false;
                }

                Accessible.role: Accessible.AlertMessage
                Accessible.name: message
                Accessible.description: Singletons.Strings.alertMessageDesc
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
                           mainStackView.push(etv,{
                                                  currentTileIndex: index,
                                                  currentTileService: currentTileService,
                                                  availableServices: asm.servicesListModel
                                              });
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
                        color: Singletons.Config.subtleBackground

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
                                            tn = availableServicesView.portal.restUrl + "/content/items/" + id + "/info/" + thumbnail + (availableServicesView.portal.signedIn ? "?token=" + availableServicesView.portal.token : "");
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
                                        family: notoRegular
                                    }
                                    color: Singletons.Config.boldUIElementFontColor
                                    verticalAlignment: Text.AlignVCenter
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                    Accessible.role: Accessible.StaticText
                                    Accessible.name: title
                                    Accessible.description: Singletons.Strings.tileServiceTitleDesc
                                }
                            }

                            Rectangle {
                                id: tileMenu
                                color: Singletons.Config.subtleBackground
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
                                            font.family: notoRegular
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
                                            font.family: notoRegular
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
                id: highlightRect
                color: "transparent"
                anchors.fill: parent
                anchors.margins: gridMargin / 2
                visible: true
                border.width: 1 * AppFramework.displayScaleFactor
                border.color: Singletons.Config.availableServicesView.highlightColor
            }

            Rectangle {
                width: servicesGridView.cellWidth / 6
                height: servicesGridView.cellWidth / 6
                radius: (servicesGridView.cellWidth / 6) / 2
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
                    color: Singletons.Config.availableServicesView.highlightColor
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    Dialog {
        id: metadataDialog
        visible: false
        title: "Metadata"
        modality: Qt.ApplicationModal

        Accessible.role: Accessible.Dialog
        Accessible.name: title
        Accessible.description: Singletons.Strings.metadataDialogDesc

        contentItem: Rectangle {
            color: Singletons.Config.subtleBackground
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
                    font.family: notoRegular
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

    Menu {
        id: contextMenu
        width: sf(200)
        padding: sf(1)

        property int menuItemHeight: sf(35)
        property var currentInfo: asm.servicesListModel.get(servicesGridView.currentIndex)

        background: Rectangle {
            color: "#fff"
            border {
                width: sf(1)
                color: Singletons.Config.subtleBackground
            }
        }

        Button {
            height: contextMenu.menuItemHeight
            width: parent.width
            background: Rectangle {
                color: parent.hovered ? Singletons.Config.subtleBackground : "#fff"
            }
            contentItem: Text {
                anchors.fill: parent
                anchors.leftMargin: sf(10)
                text: Singletons.Strings.viewMetadata
                color: Singletons.Config.boldUIElementFontColor
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: {
                metadataTextArea.clear();
                metadataTextArea.append("<h2>Description</h2>");
                metadataTextArea.append(contextMenu.currentInfo.description);
                metadataTextArea.append("<p>&nbsp;</p>");
                metadataTextArea.append("<h2>Spatial Reference</h2>");
                metadataTextArea.append(contextMenu.currentInfo.spatialReference);
                metadataTextArea.append("<p>&nbsp;</p>");
                metadataTextArea.append("<h2>Modified</h2>");
                metadataTextArea.append(new Date(contextMenu.currentInfo.modified).toDateString());
                metadataTextArea.append("<p>&nbsp;</p>");
                metadataTextArea.append("<h2>Owner</h2>");
                metadataTextArea.append(contextMenu.currentInfo.owner);
                metadataTextArea.append("<p>&nbsp;</p>");
                metadataTextArea.append("<h2>License Information</h2>");
                metadataTextArea.append(contextMenu.currentInfo.licenseInfo);
                metadataDialog.title = contextMenu.currentInfo.title;
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
            color: Singletons.Config.subtleBackground
        }

        Button {
            height: visible ? contextMenu.menuItemHeight : 0
            width: parent.width
            visible: contextMenu.currentInfo !== undefined ? contextMenu.currentInfo.isArcgisTileService || portal.isPortal : false
            enabled: contextMenu.currentInfo !== undefined ? contextMenu.currentInfo.isArcgisTileService || portal.isPortal : false
            background: Rectangle {
                color: parent.hovered ? Singletons.Config.subtleBackground : "#fff"
            }
            contentItem: Text {
                anchors.fill: parent
                anchors.leftMargin: sf(10)
                text: !portal.isPortal ? Singletons.Strings.viewOnArcgis : Singletons.Strings.viewOnPortal
                color: Singletons.Config.boldUIElementFontColor
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: {
                var baseUrl = !portal.isPortal ? "http://www.arcgis.com/home" : portal.portalUrl + "/home";
                Qt.openUrlExternally( baseUrl + "/item.html?id=" + contextMenu.currentInfo.id + "&token="+ availableServicesView.portal.token);
            }
            Accessible.role: Accessible.MenuItem
            Accessible.name: text
            Accessible.description: Singletons.Strings.viewOnArcgisOrPortalDesc
        }

        Rectangle {
            height: sf(1)
            width: parent.width
            color: Singletons.Config.subtleBackground
            visible: contextMenu.currentInfo !== undefined ? contextMenu.currentInfo.isArcgisTileService || portal.isPortal : false
        }

        Button {
            height: contextMenu.menuItemHeight
            width: parent.width
            background: Rectangle {
                color: parent.hovered ? Singletons.Config.subtleBackground : "#fff"
            }
            contentItem: Text {
                anchors.fill: parent
                anchors.leftMargin: sf(10)
                text: contextMenu.currentInfo !== undefined ? ( contextMenu.currentInfo.isArcgisTileService ? Singletons.Strings.viewRestService : Singletons.Strings.viewOnlineService) : ""
                color: Singletons.Config.boldUIElementFontColor
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: {
                var tileUrl = contextMenu.currentInfo.url.toString();

                if (contextMenu.currentInfo.isArcgisTileService) {
                    if (contextMenu.currentInfo.useTokenToAccess) {
                        Qt.openUrlExternally(tileUrl + (availableServicesView.portal.signedIn ? "?token=" + availableServicesView.portal.token : ""));
                    }
                    else{
                        Qt.openUrlExternally(tileUrl);
                    }
                }
                else {
                    Qt.openUrlExternally(tileUrl);
                }
            }
            Accessible.role: Accessible.MenuItem
            Accessible.name: text
            Accessible.description: Singletons.Strings.viewOnlineServiceDesc
        }

        Rectangle {
            height: sf(1)
            width: parent.width
            color: Singletons.Config.subtleBackground
        }

        Button {
            height: contextMenu.menuItemHeight
            width: parent.width
            background: Rectangle {
                color: parent.hovered ? Singletons.Config.subtleBackground : "#fff"
            }
            contentItem: Text {
                anchors.fill: parent
                anchors.leftMargin: sf(10)
                text: Singletons.Strings.createPItem
                color: Singletons.Config.boldUIElementFontColor
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: {
                tpkPItem.create(contextMenu.currentInfo);
            }
            Accessible.role: Accessible.MenuItem
            Accessible.name: text
            Accessible.description: Singletons.Strings.createPItemDesc
        }

        Accessible.role: Accessible.PopupMenu
        Accessible.name: Singletons.Strings.contextMenuDesc
    }

    //--------------------------------------------------------------------------

    TilePackagePItem {
        id: tpkPItem

        onSuccess: {
            viewStatusIndicator.messageType = viewStatusIndicator.success
            viewStatusIndicator.message = Singletons.Strings.fileSavedToX.arg(path)
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

    // END /////////////////////////////////////////////////////////////////////

}
