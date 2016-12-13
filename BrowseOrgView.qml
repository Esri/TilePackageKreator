import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
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

    Stack.onStatusChanged: {
        if(Stack.status === Stack.Deactivating){
            mainView.appToolBar.toolBarTitleLabel = "";
        }
        if(Stack.status === Stack.Activating){
            mainView.appToolBar.enabled = true;
            mainView.appToolBar.historyButtonEnabled = true;
            mainView.appToolBar.backButtonEnabled = true;
            mainView.appToolBar.backButtonVisible = true;
            mainView.appToolBar.toolBarTitleLabel = qsTr("Browse Organization Tile Packages")
        }
    }

    // UI //////////////////////////////////////////////////////////////////////

    Rectangle {
        id: servicesGrid
        color: "white"
        anchors.fill: parent

        Rectangle {
            id: activityIndicator
            anchors.fill: parent
            visible: false
            color: config.subtleBackground
            opacity: .8
            z: 1000

            Rectangle{
                width: 80 * AppFramework.displayScaleFactor
                height: 80 * AppFramework.displayScaleFactor
                anchors.centerIn: parent
                color: "transparent"

                Text{
                    id: refreshSpinner
                    anchors.centerIn: parent
                    font.pointSize: config.largeFontSizePoint * 3
                    color: "#888"
                    font.family: icons.name
                    text: icons.spinner2
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
        id: placeholderDelegate
        Rectangle {
            id: placeholderTileContainer
            color: "transparent"
            width: servicesGridView.cellWidth
            height: servicesGridView.cellHeight
            Rectangle {
                id: placeholderTileContent
                color: config.availableServicesView.tileItemBackgroundColor
                border.color: config.availableServicesView.tileItemBorderColor
                border.width: gridMargin / 2
                anchors.fill: parent
                anchors.margins: gridMargin / 2
                Rectangle {
                    id: placeholderInnerTile
                    anchors.fill: parent
                    anchors.margins: gridMargin / 2 + 5
                    ColumnLayout {
                        spacing: 0
                        anchors.fill: parent
                        Rectangle {
                            Layout.preferredWidth: placeholderInnerTile.width
                            Layout.preferredHeight: (placeholderInnerTile.width / thumbnailWidth * thumbnailHeight)
                            color: "#f1f1f1"
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "#fafafa"
                            Text {
                                text: title
                                anchors.fill: parent
                                font {
                                    pointSize: config.smallFontSizePoint
                                }
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            }
                        }
                        Rectangle {
                            color: "white"
                            Layout.preferredHeight: 30
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: tileServiceDelegate

        Item {

            Rectangle {
                id: tileContainer
                color: "transparent"
                width: servicesGridView.cellWidth
                height: servicesGridView.cellHeight

                MouseArea {
                    id: tileClick
                    anchors.fill: parent
                    onClicked: {
                        servicesGridView.currentIndex = index;
                    }
                    onDoubleClicked: {
                        servicesGridView.currentIndex = index;
                    }
                }

                Rectangle {
                    id: tileContent
                    color: config.availableServicesView.tileItemBackgroundColor
                    border.color: config.availableServicesView.tileItemBorderColor
                    border.width: gridMargin / 2
                    anchors.fill: parent
                    anchors.margins: gridMargin / 2

                    Rectangle {
                        id: innerTile
                        anchors.fill: parent
                        anchors.margins: gridMargin / 2 + 5

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
                                        tn = browseOrganizationTpksView.portal.restUrl + "/content/items/" + id + "/info/" + thumbnail + (browseOrganizationTpksView.portal.signedIn ? "?token=" + browseOrganizationTpksView.portal.token : "");
                                    }
                                    return tn;
                                })(thumbnail)
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "#fafafa"
                                Text {
                                    text: title
                                    anchors.fill: parent
                                    font {
                                        pointSize: config.smallFontSizePoint
                                    }
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                }
                            }

                            Rectangle {
                                id: tileMenu
                                color: "white"
                                Layout.preferredHeight: 30
                                Layout.fillWidth: true

                                RowLayout{
                                    anchors.fill: parent
                                    spacing:0
                                    Rectangle {
                                        id: tileWebMercIndicatorContainer
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true

                                        Text {
                                            id: tileWebMercIndicator
                                            anchors.fill: parent
                                            anchors.leftMargin: 10 * AppFramework.displayScaleFactor
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignLeft
                                            font.pointSize: config.xSmallFontSizePoint
                                            text: isWebMercator ? "Web Mercator" : "NOT Web Mercator"
                                            color: isWebMercator ? "#007ac2" : "red"
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
                                                }
                                                ColorOverlay {
                                                    anchors.fill: tileMenuBtnIcon
                                                    source: tileMenuBtnIcon
                                                    color: control.hovered ? app.info.properties.mainButtonBackgroundColor : "#ccc"
                                                }
                                            }
                                        }
                                        onClicked: {
                                            tileMenuMenu.popup();
                                        }
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
                                }

                                MenuItem {
                                    text: qsTr("Download via Web Browser")
                                    onTriggered: {
                                        Qt.openUrlExternally("http://www.arcgis.com/sharing/rest/content/items/" + servicesListModel.get(tileMenuMenu.tileIndex).id + "/data?token="+ portal.token);
                                    }
                                }

                                MenuItem {
                                    text: qsTr("View on ArcGIS")
                                    onTriggered: {
                                        Qt.openUrlExternally("http://www.arcgis.com/home/item.html?id=" + servicesListModel.get(tileMenuMenu.tileIndex).id + "&token="+ portal.token);
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

    Dialog {
        id: metadataDialog
        visible: false
        title: "Metadata"
        modality: Qt.WindowModal

        contentItem: Rectangle {
            color: config.subtleBackground
            anchors.fill: parent
            width: browseOrganizationTpksView.parent.width - 10
            height: browseOrganizationTpksView.parent.height - 10
            implicitWidth: browseOrganizationTpksView.parent.width - 10
            implicitHeight: browseOrganizationTpksView.parent.height - 10

            ColumnLayout {
                spacing: 1
                anchors.fill: parent

                Rectangle {
                    Layout.preferredHeight: 60
                    Layout.fillWidth: true
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
                        }

                        Button {
                            id: closeBtn
                            Layout.preferredWidth: 60
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
                                    }
                                    ColorOverlay {
                                        anchors.fill: closeBtnIcon
                                        source: closeBtnIcon
                                        color: closeBtn.pressed ? app.info.properties.mainButtonPressedColor : app.info.properties.mainButtonBackgroundColor
                                    }
                                }
                            }
                            onClicked: {
                                metadataTextArea.text = "";
                                metadataTitle.text = "Metadata";
                                metadataDialog.close();
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    TextArea {
                        id: metadataTextArea
                        anchors.fill: parent
                        anchors.margins: 10
                        text: ""
                        textColor: app.info.properties.toolBarBackgroundColor
                        readOnly: true
                        frameVisible: false
                        textFormat: Text.RichText
                        onLinkActivated: {
                            Qt.openUrlExternally(link);
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
            width: servicesGridView.cellWidth * AppFramework.displayScaleFactor
            height: servicesGridView.cellHeight * AppFramework.displayScaleFactor
            x: servicesGridView.currentItem.x
            y: servicesGridView.currentItem.y
            z: 1000

            Rectangle {
                id: highlightRect
                color: "transparent"
                anchors.fill: parent
                anchors.margins: (gridMargin / 2) * AppFramework.displayScaleFactor
                visible: true
                border.width: 1 * AppFramework.displayScaleFactor
                border.color: config.availableServicesView.highlightColor
            }

            Rectangle {
                width: servicesGridView.cellWidth / 6 * AppFramework.displayScaleFactor
                height: servicesGridView.cellWidth / 6 * AppFramework.displayScaleFactor
                radius: (servicesGridView.cellWidth / 6) / 2 * AppFramework.displayScaleFactor
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 15 * AppFramework.displayScaleFactor
                anchors.leftMargin: 15 * AppFramework.displayScaleFactor
                Image {
                    id: tileSelectedIcon
                    source: "images/checkmark_inverted.png"
                    width: parent.width - 2 * AppFramework.displayScaleFactor
                    height: parent.width - 2 * AppFramework.displayScaleFactor
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
