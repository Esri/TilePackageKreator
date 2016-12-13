import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
//------------------------------------------------------------------------------
import "HistoryManager"

Item {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: historyView

    property Config config
    property bool exportHistoryExists: false
    property bool uploadHistoryExists: false

    // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////////

    Component.onCompleted: {
        getExportHistory();
        getUploadHistory();
    }

    //--------------------------------------------------------------------------

    Stack.onStatusChanged: {
        if(Stack.status === Stack.Deactivating){
            mainView.appToolBar.toolBarTitleLabel = "";
        }
        if(Stack.status === Stack.Activating){
            mainView.appToolBar.enabled = true;
            mainView.appToolBar.historyButtonEnabled = false;
            mainView.appToolBar.backButtonEnabled = true;
            mainView.appToolBar.backButtonVisible = true;
            mainView.appToolBar.toolBarTitleLabel = qsTr("Export and Upload History");
        }
    }

    // UI //////////////////////////////////////////////////////////////////////

    RowLayout{
        anchors.fill: parent
        anchors.margins: 10 * AppFramework.displayScaleFactor
        anchors.topMargin: 0
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            Rectangle{
                anchors.fill: parent
                anchors.rightMargin:10 * AppFramework.displayScaleFactor

                color:"white"

                ColumnLayout{
                    spacing: 0
                    anchors.fill: parent

                    Rectangle{
                        Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                        Layout.fillWidth: true

                        RowLayout{
                            anchors.fill: parent
                            Text{
                                id: exportHistoryLabel
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                text: qsTr("Export History")
                                font.pointSize: config.mediumFontSizePoint
                                font.family: notoRegular.name
                                verticalAlignment: Text.AlignVCenter
                            }
                            Rectangle{
                                Layout.fillHeight: true
                                Layout.preferredWidth: 150 * AppFramework.displayScaleFactor
                                Button{
                                    anchors.fill: parent
                                    enabled: exportHistoryExists
                                    visible: exportHistoryExists

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
                                        text: qsTr("Delete History")
                                        font.pointSize: config.baseFontSizePoint
                                        font.family: notoRegular.name
                                    }

                                    onClicked: {
                                        history.deleteHistory(history.exportHistoryKey);
                                        getExportHistory();
                                    }
                                }

                            }
                        }
                    }

                    // ---------------------------------------------------------

                    Rectangle{
                        Layout.preferredHeight: 1 * AppFramework.displayScaleFactor
                        Layout.fillWidth: true
                        Layout.bottomMargin: 10 * AppFramework.displayScaleFactor
                        color: "#ddd"
                    }

                    // ---------------------------------------------------------

                    TextArea {
                        id: exportHistoryTextArea
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        textFormat: Text.RichText
                        readOnly: true
                        font.pointSize: config.baseFontSizePoint
                        textColor: app.info.properties.toolBarBackgroundColor
                        wrapMode: Text.Wrap
                        backgroundVisible: false
                        frameVisible: false
                        onLinkActivated: {
                            Qt.openUrlExternally(link);
                        }
                        Component.onCompleted: {
                            flickableItem.contentY = 0;
                        }
                    }
                }
            }
        }

        //------------------------------------------------------------------

        Rectangle{
            Layout.preferredWidth: 1 * AppFramework.displayScaleFactor
            Layout.fillHeight: true
            color: app.info.properties.toolBarBackgroundColor
        }

        //------------------------------------------------------------------

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            //Layout.margins: 10 * AppFramework.displayScaleFactor
            clip: true

            Rectangle{
                anchors.fill: parent
                anchors.leftMargin: 10 * AppFramework.displayScaleFactor
                color:"white"

                ColumnLayout{
                    spacing: 0
                    anchors.fill: parent

                    Rectangle{
                        Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                        Layout.fillWidth: true

                        RowLayout{
                            anchors.fill: parent
                            Text{
                                id: uploadHistoryLabel
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                text: qsTr("Upload History")
                                font.pointSize: config.mediumFontSizePoint
                                font.family: notoRegular.name
                                verticalAlignment: Text.AlignVCenter
                            }
                            Rectangle{
                                Layout.fillHeight: true
                                Layout.preferredWidth: 150 * AppFramework.displayScaleFactor

                                Button{
                                    anchors.fill: parent
                                    enabled: uploadHistoryExists
                                    visible: uploadHistoryExists
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
                                        text: qsTr("Delete History")
                                        font.pointSize: config.baseFontSizePoint
                                        font.family: notoRegular.name
                                    }

                                    onClicked: {
                                        history.deleteHistory(history.uploadHistoryKey);
                                        getUploadHistory();
                                    }
                                }
                            }
                        }
                    }

                    // ---------------------------------------------------------

                    Rectangle{
                        Layout.preferredHeight: 1 * AppFramework.displayScaleFactor
                        Layout.fillWidth: true
                        Layout.bottomMargin: 10 * AppFramework.displayScaleFactor
                        color: "#ddd"
                    }

                    // ---------------------------------------------------------

                    TextArea {
                        id: uploadHistoryTextArea
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        textFormat: Text.RichText
                        readOnly: true
                        font.pointSize: config.baseFontSizePoint
                        textColor: app.info.properties.toolBarBackgroundColor
                        wrapMode: Text.Wrap
                        backgroundVisible: false
                        frameVisible: false
                        onLinkActivated: {
                            Qt.openUrlExternally(link);
                        }
                        Component.onCompleted: {
                            flickableItem.contentY = 0;
                        }
                    }
                }
            }
        }
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    HistoryManager{
        id: history
    }

    // METHODS /////////////////////////////////////////////////////////////////

    function getExportHistory(){
        exportHistoryTextArea.text = "";
        var exportHistory = history.readHistory(history.exportHistoryKey);
        if(exportHistory !== null && exportHistory.length > 0){
            var reversedHistory = exportHistory.reverse();
            for(var i=0; i < reversedHistory.length; i++){
               exportHistoryTextArea.append("<h3 style=\"color:darkorange;\">" + reversedHistory[i].serviceTitle + "</h3>");
               exportHistoryTextArea.append("<p>" + new Date(reversedHistory[i].export_date).toLocaleDateString() + " " + new Date(reversedHistory[i].export_date).toLocaleTimeString() + "</p>");
               exportHistoryTextArea.append("<h4>Tile Service</h4>");
               exportHistoryTextArea.append(reversedHistory[i].service);
               var extent = JSON.parse(reversedHistory[i].extent)
               exportHistoryTextArea.append("<h4>Geometry</h4>");
                    exportHistoryTextArea.append("<p>" + JSON.stringify(extent.geometries) + "<br/>");
                    if(reversedHistory[i].hasOwnProperty("buffer")){
                        exportHistoryTextArea.append("Buffer: " + reversedHistory[i].buffer + "</p><hr/>");
                    }
                    exportHistoryTextArea.append("Type: " + extent.geometryType + "</p><hr/>");
               exportHistoryTextArea.append("<h4>Export Parameters</h4>");
               exportHistoryTextArea.append("<p>Levels: " + reversedHistory[i].levels + "</p>");
               exportHistoryTextArea.append("<p>Package Size: " + reversedHistory[i].package_size + "</p>");
               exportHistoryTextArea.append("<p>Number of Tiles: " + reversedHistory[i].number_of_tiles + "</p>");
               exportHistoryTextArea.append("<p>Description: " + reversedHistory[i].serviceDescription + "</p>");
               exportHistoryTextArea.append("<h4>File Information</h4>");
               exportHistoryTextArea.append("<p>Local File Path: " + reversedHistory[i].filepath + "</p>");
               exportHistoryTextArea.append("<a href=\"" + reversedHistory[i].download_url + "\">Download Link [link may have expired]</a>");
             }
            exportHistoryExists = true;
        }
        else{
            exportHistoryTextArea.append("<p>No Export History Available<p>");
            exportHistoryExists = false;
        }
    }

    //--------------------------------------------------------------------------

    function getUploadHistory(){
        uploadHistoryTextArea.text = "";
        var uploadHistory = history.readHistory(history.uploadHistoryKey);
        if(uploadHistory !== null && uploadHistory.length > 0){
            var reversedHistory = uploadHistory.reverse();
            for(var i=0; i < reversedHistory.length; i++){
               uploadHistoryTextArea.append("<h3 style=\"color:darkblue;\">" + reversedHistory[i].title + "</h3>");
               uploadHistoryTextArea.append("<p>" + new Date(reversedHistory[i].transaction_date).toLocaleDateString() + " " + new Date(reversedHistory[i].transaction_date).toLocaleTimeString() + "</p>");
               uploadHistoryTextArea.append("<p>Description: " + reversedHistory[i].description + "</p>");
               uploadHistoryTextArea.append("<a href=\"" + reversedHistory[i].service_url + "\">Published ArcGIS Service Link</a>");
            }
            uploadHistoryExists = true;
        }
        else{
            uploadHistoryTextArea.append("<p>No Upload History Available<p>");
            uploadHistoryExists = false;
        }
    }

    // END /////////////////////////////////////////////////////////////////////
}
