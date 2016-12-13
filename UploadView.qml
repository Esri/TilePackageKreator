import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.2
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
//------------------------------------------------------------------------------
import "Portal"
import "TilePackage"
import "ProgressIndicator"
import "HistoryManager"
//------------------------------------------------------------------------------

Item {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: uploadView

    property Portal portal
    property Config config
    property var currentTPKUrl: null

    property bool fileAcceptedForUpload: false
    property bool uploading: false

    signal uploadStarted()
    signal uploadComplete()

    // SIGNAL IMPLEMENTATION ///////////////////////////////////////////////////

    Component.onCompleted: {
        if(calledFromAnotherApp){
            if(dlr.filePath !== null){
                fileInfo.filePath = dlr.filePath
                if(fileInfo.exists){
                    fileAccepted(dlr.filePath);
                }
                else{
                    uploadStatusIndicator.messageType = uploadStatusIndicator.error;
                    uploadStatusIndicator.message =  "The .tpk file does not exist. <a href='%1'>Return to %2</a>".arg(dlr.successCallback).arg(dlr.callingApplication);
                    uploadStatusIndicator.show();
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    Stack.onStatusChanged: {
        if(Stack.status === Stack.Deactivating){
            mainView.appToolBar.toolBarTitleLabel = "";
        }
        if(Stack.status === Stack.Activating){
            mainView.appToolBar.backButtonEnabled = (!calledFromAnotherApp) ? true : false
            mainView.appToolBar.backButtonVisible = (!calledFromAnotherApp) ? true : false
            mainView.appToolBar.historyButtonEnabled = true;
            mainView.appToolBar.toolBarTitleLabel = qsTr("Upload Local Tile Package")
        }
    }

    //--------------------------------------------------------------------------

    onFileAcceptedForUploadChanged: {
        if(fileAcceptedForUpload){
            uploadStatusIndicator.hide();
        }
        else{
            resetProperties();
        }
    }

    //--------------------------------------------------------------------------

    onUploadingChanged: {
        mainView.appToolBar.enabled = uploading ? false : true;
    }

    //--------------------------------------------------------------------------

    onUploadStarted: {
        uploading = true;
        uploadStatusIndicator.hide();
    }

    //--------------------------------------------------------------------------

    onUploadComplete: {
        uploading = false;
        fileAcceptedForUpload = false;
        statusWebMercCheck.progressIcon = "";
        statusWebMercCheck.progressText = "";
        selectedTPKFileName.text = "no file chosen";
        tpkUploadDetails.reset();
        resetProperties();
    }

    // UI //////////////////////////////////////////////////////////////////////

    Rectangle {
        anchors.fill: parent
        color: "#eee"

        ColumnLayout {
            id: uploadTPKViewColumnLayout
            anchors.fill: parent
            spacing: 1 * AppFramework.displayScaleFactor

            // MAIN SECTION ////////////////////////////////////////////////////

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                color: config.subtleBackground

                RowLayout {
                    id: tpkForm
                    anchors.fill: parent
                    spacing: 1
                    enabled: uploading ? false : true

                    // DRAG AND DROP AREA //////////////////////////////////////

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "#fff"

                        Rectangle {
                            color: config.boldUIElementBackground
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.margins: 12 * AppFramework.displayScaleFactor

                            Rectangle {
                                id: selectTPK
                                width: 200 * AppFramework.displayScaleFactor
                                height: 200 * AppFramework.displayScaleFactor
                                anchors.centerIn: parent
                                color: "transparent"
                                enabled: fileAcceptedForUpload ? false : true
                                visible: fileAcceptedForUpload ? false : true

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 0

                                    Text {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: selectTPK.height / 3
                                        text: "Drag .tpk file here"
                                        color: config.boldUIElementFontColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pointSize: config.largeFontSizePoint
                                        font.family: notoRegular.name
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: selectTPK.height / 3
                                        text: "or"
                                        color: config.boldUIElementFontColor
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.family: notoRegular.name
                                    }
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: selectTPK.height / 3
                                        color: "transparent"

                                        Button {
                                            id: openFileChooserBtn
                                            anchors.fill: parent
                                            anchors.margins: 10 * AppFramework.displayScaleFactor
                                            enabled: uploading ? false : true

                                            style: ButtonStyle {
                                                background: Rectangle {
                                                    anchors.fill: parent
                                                    color:config.buttonStates(control)
                                                    radius: app.info.properties.mainButtonRadius
                                                    border.width: (control.enabled) ? app.info.properties.mainButtonBorderWidth : 0
                                                    border.color: app.info.properties.mainButtonBorderColor
                                                }
                                            }

                                            Text {
                                                color: app.info.properties.mainButtonFontColor
                                                anchors.centerIn: parent
                                                textFormat: Text.RichText
                                                text: "Browse for file"
                                                font.pointSize: config.baseFontSizePoint
                                                font.family: notoRegular.name
                                            }
                                            onClicked: {
                                                resetProperties();
                                                fileChooser.open();
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                id: selectedTPK
                                width: 200 * AppFramework.displayScaleFactor
                                height: 200 * AppFramework.displayScaleFactor
                                anchors.centerIn: parent
                                color: "transparent"
                                visible: fileAcceptedForUpload ? true : false
                                enabled: fileAcceptedForUpload ? true : false

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 0

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: selectedTPK.height / 4
                                        color: "transparent"
                                        Image {
                                            id: tpkIcon
                                            source: fileAcceptedForUpload ? "images/happy_face.png" : "images/sad_face.png"
                                            height: parent.height
                                            fillMode: Image.PreserveAspectFit
                                            anchors.centerIn: parent
                                        }
                                    }

                                    Text {
                                        id: selectedTPKFileName
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: selectedTPK.height / 4
                                        text: "filename.tpk"
                                        fontSizeMode: Text.Fit
                                        font.family: notoRegular.name
                                        minimumPointSize: config.smallFontSizePoint
                                        color: config.boldUIElementFontColor
                                        font.pointSize: config.largeFontSizePoint
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    ProgressIndicator {
                                        id: statusWebMercCheck
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: selectedTPK.height / 4 - 10
                                        statusTextLeftMargin:10 * AppFramework.displayScaleFactor
                                        iconContainerLeftMargin: 5 * AppFramework.displayScaleFactor
                                        iconContainerHeight: this.containerHeight - 5
                                        containerHeight: selectedTPK.height / 4 - 10
                                        statusText.horizontalAlignment: Text.AlignHCenter
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: selectedTPK.height / 4
                                        color: "transparent"

                                        Button {
                                            id: changeTPKFileBtn
                                            anchors.fill: parent
                                            anchors.margins: 10 * AppFramework.displayScaleFactor

                                            style: ButtonStyle {
                                                background: Rectangle {
                                                    anchors.fill: parent
                                                    color: "transparent"
                                                    radius: app.info.properties.mainButtonRadius
                                                    border.width: 0
                                                    border.color: app.info.properties.mainButtonBorderColor
                                                }
                                            }

                                            Text {
                                                color: app.info.properties.mainButtonBackgroundColor
                                                anchors.centerIn: parent
                                                textFormat: Text.RichText
                                                text: "Use a different file"
                                                font.pointSize: config.baseFontSizePoint
                                                font.family: notoRegular.name
                                            }
                                            onClicked: {
                                                fileAcceptedForUpload = false;
                                            }
                                        }
                                    }
                                }
                            }

                            DropArea {
                                id: tpkDropArea
                                anchors.fill: parent
                                enabled: uploading ? false : true
                                onEntered: {
                                    if (isTPKFile(drag.urls.toString())) {
                                        tpkIcon.source = "images/happy_face.png";
                                    } else {
                                        tpkIcon.source = "images/sad_face.png";
                                    }
                                }
                                onDropped: {
                                    statusWebMercCheck.visible = false
                                    if (isTPKFile(drop.urls.toString())) {
                                        fileAccepted(AppFramework.resolvedUrl(drop.urls[0]));
                                    } else {
                                        tpkIcon.source = "images/sad_face.png";
                                        selectedTPKFileName.text = ".tpk files only please";
                                        tpkUploadDetails.tpkTitle = "";
                                    }
                                }
                            }
                        }
                    }

                    // FORM DETAILS ////////////////////////////////////////////

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 350 * AppFramework.displayScaleFactor
                        color: "#fff"

                        DetailsForm {
                            id: tpkUploadDetails
                            anchors.fill: parent
                            enabled: uploading ? false : true
                            config: uploadView.config

                            exportAndUpload: false
                            exportPathBuffering: false
                        }
                    }
                }

                // UPLOAD OVERLAY //////////////////////////////////////////////

                Rectangle{
                    id: tpkUploadStatusOverlay
                    color:config.subtleBackground
                    opacity: .9
                    anchors.fill: parent
                    visible: uploading ? true : false
                }
            }

            // BOTTOM TASK BAR /////////////////////////////////////////////////

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60 * AppFramework.displayScaleFactor
                color: "#fff"

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        color: "#fff"
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        Rectangle{
                            id: uploadStatusContainer
                            anchors.fill: parent
                            anchors.margins: 10 * AppFramework.displayScaleFactor

                            StatusIndicator{
                                id: uploadStatusIndicator
                                anchors.fill: parent
                                containerHeight: parent.height
                                hideAutomatically: true
                                showDismissButton: true
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 140 * AppFramework.displayScaleFactor
                        color: "#fff"

                        Button {
                            id: uploadTPKBtn
                            enabled: (!fileAcceptedForUpload || uploading) ? false : true
                            anchors.fill: parent
                            anchors.margins: 10 * AppFramework.displayScaleFactor
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
                                spacing:0
                                anchors.fill: parent

                                Text {
                                    id: uploadTPKBtnText
                                    color: app.info.properties.mainButtonFontColor
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    textFormat: Text.RichText
                                    text: uploading ? ( tpkPackage.aborted ? qsTr("Cancelling") : qsTr("Uploading") ): qsTr("Upload")
                                    font.pointSize: config.baseFontSizePoint
                                    font.family: notoRegular.name
                                }

                                ProgressIndicator{
                                    id:statusUploadStatus
                                    visible: uploading ? true : false
                                    Layout.preferredWidth: parent.height
                                    containerHeight: parent.height
                                    progressIndicatorBackground: "transparent"
                                    iconContainerBackground: "transparent"
                                    statusText.visible: false
                                    progressIcon: uploading ? statusUploadStatus.working : ""
                                    progressText: uploading ? "" : ""
                                }
                            }

                            onClicked: {
                                if (currentTPKUrl !== null) {
                                    uploadStarted();
                                    tpkPackage.upload(currentTPKUrl, tpkUploadDetails.tpkTitle, tpkUploadDetails.tpkDescription);
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 140 * AppFramework.displayScaleFactor
                        color: "#fff"
                        visible: uploading
                        Button {
                            id: uploadCancelBtn
                            anchors.fill: parent
                            anchors.margins: 10
                            enabled: uploading ? (tpkPackage.aborted ? false : true) : false

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
                                color: (!tpkPackage.aborted) ? app.info.properties.mainButtonBackgroundColor : "#aaa"
                                anchors.centerIn: parent
                                textFormat: Text.RichText
                                text: "Cancel"
                                font.pointSize: config.baseFontSizePoint
                                font.family: notoRegular.name
                            }

                            onClicked: {
                                tpkPackage.cancel();
                            }
                        }
                    }
                }
            }
        }
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    FileDialog {

        id: fileChooser
        title: "Please choose a Tile Package (.tpk)"
        selectMultiple: false
        nameFilters: ["TPK (*.tpk)"]
        modality: Qt.WindowModal
        onAccepted: {
            fileAccepted(fileChooser.fileUrl);
            fileChooser.close();
        }
        onRejected: {
            fileAcceptedForUpload = false;
            fileChooser.close();
        }
    }

    //--------------------------------------------------------------------------

    FileInfo {
        id: fileInfo
    }

    //--------------------------------------------------------------------------

    TilePackageUpload {

        id: tpkPackage
        portal: uploadView.portal

        onSrCheckComplete: {
            if (tpkPackage.isWebMercator) {
                statusWebMercCheck.progressIcon = statusWebMercCheck.success;
                statusWebMercCheck.progressText = "Web Mercator";
            } else {
                statusWebMercCheck.progressIcon = statusWebMercCheck.failed;
                statusWebMercCheck.progressText = "NOT WEB MERCATOR";
            }
        }

        onUploadStarted: {
        }

        onUploadComplete: {
            try {
                var uploadData = {
                    transaction_date: Date.now(),
                    title: tpkUploadDetails.tpkTitle,
                    description: tpkUploadDetails.tpkDescription,
                    service_url: portal.owningSystemUrl + "/home/item.html?id=" + id
                }
                history.writeHistory(history.uploadHistoryKey, uploadData);
            } catch (error) {
                appMetrics.reportError(error);
            } finally {
                if (tpkUploadDetails.currentSharing !== "") {
                    uploadTPKUpdate.share(id, tpkUploadDetails.currentSharing);
                }
                else{
                    uploadStatusIndicator.messageType = uploadStatusIndicator.success;
                    if(calledFromAnotherApp && dlr.successCallback !== ""){
                        uploadStatusIndicator.message = "Upload Complete. <a href='%1?isShared=%2&isOnline=%3&itemId=%4'>Return to %5</a>".arg(dlr.successCallback).arg("false").arg("true").arg(id).arg(dlr.callingApplication);
                    }
                    else{
                        uploadStatusIndicator.message =  "Upload Complete. <a href=\"" + portal.owningSystemUrl + "/home/item.html?id=" + id + "\">View Online</a>";
                    }

                    uploadStatusIndicator.show();
                    uploadView.uploadComplete();
                }
            }
        }

        onUploadCancelled: {
            uploadStatusIndicator.messageType = uploadStatusIndicator.info;
            uploadStatusIndicator.message =  "Upload Cancelled";
            uploadStatusIndicator.show();
            uploadView.uploadComplete();
        }

        onUploadProgress: {
        }

        onUploadFailed: {
            uploadStatusIndicator.messageType = uploadStatusIndicator.error;

            if(error.message.indexOf("already exists") > -1){
                error.message = "A tpk file with that name already exists.";
            }

            try{
                throw new Error(error.message);
            }
            catch(e){
                appMetrics.reportError(e)
            }

            uploadStatusIndicator.message =  "Upload Failed. " + error.message;
            uploadStatusIndicator.show();
            uploadView.uploadComplete();
        }

        onUploadError: {
            uploadStatusIndicator.messageType = uploadStatusIndicator.error;
            uploadStatusIndicator.message =  "Upload Failed. Error: " + error;
            uploadStatusIndicator.show();
            uploadView.uploadComplete();

            try{
                throw new Error(error);
            }
            catch(e){
                appMetrics.reportError(e)
            }
        }
    }

    //--------------------------------------------------------------------------

    TilePackageUpdate {
        id: uploadTPKUpdate
        portal: uploadView.portal
        onShared: {
            uploadStatusIndicator.messageType = uploadStatusIndicator.success;
            if(calledFromAnotherApp && dlr.successCallback !== ""){
                 uploadStatusIndicator.message = "Upload Complete. <a href='%1?isShared=%2&isOnline=%3&itemId=%4'>Return to %5</a>".arg(dlr.successCallback).arg("true").arg("true").arg(itemId).arg(dlr.callingApplication);
            }
            else{
                uploadStatusIndicator.message =  "Upload and Sharing Complete. <a href=\"" + portal.owningSystemUrl + "/home/item.html?id=" + itemId + "\">View Online</a>";
            }
            uploadStatusIndicator.show();
            uploadView.uploadComplete();
        }
        onUpdated: {}
        onError: {
            uploadStatusIndicator.messageType = uploadStatusIndicator.error;
            if(calledFromAnotherApp && dlr.successCallback !== ""){
                 uploadStatusIndicator.message = "Upload Complete. Error Sharing. <a href='%1?isShared=%2&isOnline=%3&itemId=%4'>Return to %5</a>".arg(dlr.successCallback).arg("false").arg("true").arg(itemId).arg(dlr.callingApplication);
            }
            else{
                uploadStatusIndicator.message =  "Upload Complete. Error Sharing. <a href=\"" + portal.owningSystemUrl + "/home/item.html?id=" + itemId + "\">View Online</a>";
            }
            uploadStatusIndicator.show();
            uploadView.uploadComplete();
        }
    }

    //--------------------------------------------------------------------------

    HistoryManager{
        id: history
    }

    // METHODS /////////////////////////////////////////////////////////////////

    function resetProperties() {
        currentTPKUrl = null;
    }

    //--------------------------------------------------------------------------

    function uiEntryElementStates(control) {
        if (!control.enabled) {
            return "#888";
        } else {
            return config.formElementBackground;
        }
    }

    //--------------------------------------------------------------------------

    function isTPKFile(item) {
        var extension = ".tpk"
        if ((item.indexOf(extension, item.lastIndexOf('/') + 1)) > -1) {
            console.log('is a tpk');
            return true;
        } else {
            console.log('is not a tpk');
            return false;
        }
    }

    //--------------------------------------------------------------------------

    function extractTPKFileName(item) {
        return item.substring(item.lastIndexOf('/') + 1, item.length);
    }

    //--------------------------------------------------------------------------

    function extractDefaultTPKTitle(filename){
        var defaultTitle;

        if(filename.indexOf("_") > -1){
            defaultTitle = filename.substring(0, filename.lastIndexOf("_"));
            defaultTitle = defaultTitle.replace(/_/g, " ");
        }
        else{
             defaultTitle = filename.substring(0,30);
        }
        return defaultTitle;
    }

    //--------------------------------------------------------------------------

    function fileAccepted(fileUrl) {
        currentTPKUrl = fileUrl;
        fileAcceptedForUpload = true;
        selectedTPKFileName.text = extractTPKFileName(fileUrl.toString());
        tpkUploadDetails.tpkTitle = extractDefaultTPKTitle(selectedTPKFileName.text);
        statusWebMercCheck.progressIcon = statusWebMercCheck.working;
        statusWebMercCheck.progressText = "Checking Spatial Reference";
        statusWebMercCheck.visible = true;
        tpkPackage.getTPKSpatialReference(currentTPKUrl);
    }
}
