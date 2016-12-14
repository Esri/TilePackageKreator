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
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtLocation 5.3
import QtPositioning 5.3
import QtGraphicalEffects 1.0
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
//------------------------------------------------------------------------------

Item {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: tpkDetailsForm

    property Config config
    property int maxLevels: 19
    property string currentSharing: ""
    property string currentExportTitle: ""
    property var currentTileService: null
    property var currentLevels: null
    property var currentExportRequest: ({})
    property var currentSaveToLocation: null
    property int currentBufferInMeters: 1
    property string defaultSaveToLocation: ""

    property bool exportAndUpload: true
    property bool exportPathBuffering: false
    property bool uploadToPortal: true
    property bool usesMetric: localeIsMetric()

    property alias tpkZoomLevels: desiredLevelsSlider.value
    //property alias tpkPathBufferDistance: desiredBufferSlider.value
    property alias tpkTitle: tpkTitleTextField.text
    //property alias tpkSharing: tpkDetailsForm.currentSharing
    property alias tpkDescription: tpkDescriptionTextArea.text
    property alias exportToFolder: folderChooser.folder

    signal exportZoomLevelsChanged()
    signal exportBufferDistanceChanged()

    // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////////

    Component.onCompleted: {
        console.log("usesMetric: ", usesMetric);
        currentBufferInMeters = (usesMetric) ? 1 : feetToMeters(1);
    }

    //--------------------------------------------------------------------------

    onExportBufferDistanceChanged: {
        console.log("usesMetric: ", usesMetric);
        currentBufferInMeters = (usesMetric) ? desiredBufferSlider.value : feetToMeters(desiredBufferSlider.value);
    }

    // UI //////////////////////////////////////////////////////////////////////

    ColumnLayout{
        anchors.fill: parent
        anchors.margins: 10 * AppFramework.displayScaleFactor
        spacing: 0

        //----------------------------------------------------------------------

        Rectangle {
            color: "#fff"
            Layout.fillWidth: true
            Layout.preferredHeight: 70 * AppFramework.displayScaleFactor
            visible: exportAndUpload
            enabled: exportAndUpload

            ColumnLayout{
                anchors.fill: parent
                spacing:0
                Text {
                    text: qsTr("Number of Zoom Levels")
                    color: config.formElementFontColor
                    font.pointSize: config.smallFontSizePoint
                    font.family: notoRegular.name
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
                Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50 * AppFramework.displayScaleFactor

                    RowLayout{
                        anchors.fill: parent
                        spacing:0

                        Slider {
                            id: desiredLevelsSlider
                            minimumValue: 0
                            maximumValue: maxLevels
                            stepSize: 1
                            tickmarksEnabled: false
                            Layout.fillWidth: true
                            Layout.rightMargin: 10 * AppFramework.displayScaleFactor
                            anchors.verticalCenter: parent.verticalCenter

                            onPressedChanged: {
                                if(pressed===false){
                                    tpkDetailsForm.exportZoomLevelsChanged();
                                }
                            }
                        }

                       TextField {
                            id: desiredLevels
                            Layout.fillHeight: true
                            Layout.preferredWidth: 40 * AppFramework.displayScaleFactor
                            readOnly: true
                            text: desiredLevelsSlider.value
                            horizontalAlignment: Text.AlignRight
                            font.pointSize: config.largeFontSizePoint
                            font.family: notoRegular.name

                            style: TextFieldStyle {
                                background: Rectangle {
                                    anchors.fill: parent
                                    border.width: 0
                                    radius: 0
                                    color: _uiEntryElementStates(control)
                                }
                                textColor: config.formElementFontColor
                                font.family: notoRegular.name
                            }
                        }
                    }
                }
            }
        }

        //----------------------------------------------------------------------

        StatusIndicator{
            id: levelsWarning
            Layout.fillWidth: true
            Layout.topMargin: 5 * AppFramework.displayScaleFactor
            containerHeight: desiredLevelsSlider.value > 15 ? 30 * AppFramework.displayScaleFactor : 1 * AppFramework.displayScaleFactor
            statusTextFontSize: config.xSmallFontSizePoint
            messageType: warning
            message: qsTr("Export may fail with this many levels if extent is too large.")
            visible: (exportAndUpload && desiredLevelsSlider.value) > 15 ? true : false
            statusTextObject.anchors.margins: 10 * AppFramework.displayScaleFactor
            statusTextObject.wrapMode: Text.Wrap
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1 * AppFramework.displayScaleFactor
            Layout.topMargin: 5 * AppFramework.displayScaleFactor
            color: config.subtleBackground
            visible: exportAndUpload
        }

        //----------------------------------------------------------------------

        Rectangle {
            color: "#fff"
            Layout.fillWidth: true
            Layout.preferredHeight: 70 * AppFramework.displayScaleFactor
            Layout.topMargin: 10 * AppFramework.displayScaleFactor
            visible: exportAndUpload && exportPathBuffering
            enabled: exportAndUpload && exportPathBuffering

            ColumnLayout{
                anchors.fill: parent
                spacing:0
                Text {
                    text: qsTr("Buffer Radius")
                    color: config.formElementFontColor
                    font.pointSize: config.smallFontSizePoint
                    font.family: notoRegular.name
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
                Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50 * AppFramework.displayScaleFactor

                    RowLayout{
                        anchors.fill: parent
                        spacing:0

                        Slider {
                            id: desiredBufferSlider
                            minimumValue: 1
                            maximumValue: usesMetric ? 1000 : 3000
                            stepSize: 1
                            tickmarksEnabled: false
                            Layout.fillWidth: true
                            Layout.rightMargin: 10 * AppFramework.displayScaleFactor
                            anchors.verticalCenter: parent.verticalCenter

                            onPressedChanged: {
                                if(pressed===false){
                                    tpkDetailsForm.exportBufferDistanceChanged();
                                }
                            }
                        }

                       TextField {
                            id: desiredBuffer
                            Layout.fillHeight: true
                            Layout.preferredWidth: 90 * AppFramework.displayScaleFactor
                            readOnly: true
                            text: "%1 %2".arg(desiredBufferSlider.value).arg(usesMetric ? "m" : "ft")
                            horizontalAlignment: Text.AlignRight
                            font.pointSize: config.largeFontSizePoint

                            style: TextFieldStyle {
                                background: Rectangle {
                                    anchors.fill: parent
                                    border.width: 0
                                    radius: 0
                                    color: _uiEntryElementStates(control)
                                }
                                textColor: config.formElementFontColor
                                font.family: notoRegular.name
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1 * AppFramework.displayScaleFactor
            Layout.topMargin: 5 * AppFramework.displayScaleFactor
            color: config.subtleBackground
            visible: exportAndUpload && exportPathBuffering
        }

        //----------------------------------------------------------------------

        ExclusiveGroup{
            id: destinationExclusiveGroup
        }

        //----------------------------------------------------------------------

        Rectangle{
            Layout.fillWidth: true
            Layout.preferredHeight: 30 * AppFramework.displayScaleFactor
            color:"#fff"

            RowLayout{
                id:tpkTitleLabels
                anchors.fill: parent
                spacing:0

                Label {
                    id: tpkTitleTextFieldLabel
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: qsTr("Title") + "<span style=\"color:red\"> *</span>"
                    textFormat: Text.RichText
                    font.pointSize: config.smallFontSizePoint
                    font.family: notoRegular.name
                    color: config.mainLabelFontColor
                    verticalAlignment: Text.AlignVCenter
                }
            }
         }

         Rectangle{
             Layout.fillWidth: true
             Layout.preferredHeight: 40 * AppFramework.displayScaleFactor
             Layout.bottomMargin: 5 * AppFramework.displayScaleFactor

            TextField {
                id: tpkTitleTextField
                anchors.fill: parent
                placeholderText: qsTr("Enter a title")

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
                onTextChanged: {
                    if(tpkTitleTextField.length > 0){
                        _sanatizeTitle(text);
                    }
                    else{
                        tpkFileTitleName.text = "";
                        currentExportTitle = "";
                    }
                }
            }
        }

        Rectangle{
            Layout.fillWidth:true
            Layout.preferredHeight: 10 * AppFramework.displayScaleFactor
            Layout.bottomMargin: 5 * AppFramework.displayScaleFactor
            visible: false
            Text{
                id: tpkFileTitleName
                anchors.fill: parent
                font.pointSize: config.xSmallFontSizePoint
                font.family: notoRegular.name
                color: config.formElementFontColor
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: config.subtleBackground
            visible: exportAndUpload
        }

        //----------------------------------------------------------------------

        Rectangle{
            Layout.fillWidth: true
            Layout.preferredHeight: 40 * AppFramework.displayScaleFactor
            color:"#fff"
            visible: exportAndUpload
            enabled: exportAndUpload

            RowLayout{
                anchors.fill: parent
                spacing: 0

                RadioButton {
                    id: saveToLocation
                    exclusiveGroup: destinationExclusiveGroup
                    onCheckedChanged: {
                        currentSaveToLocation = (dlr.saveToPath !== null) ? defaultSaveToLocation : null;
                        saveToLocationFolder.text = _extractFolderDirectory(defaultSaveToLocation);
                        saveToLocationDetails.visible = this.checked;
                    }
                }

                Text{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    verticalAlignment: Text.AlignVCenter
                    color: config.formElementFontColor
                    font.pointSize: config.smallFontSizePoint
                    font.family: notoRegular.name
                    text: qsTr("Save tile package locally")
                }
            }
        }

        Rectangle{
            id: saveToLocationDetails
            color:"#fff"
            Layout.fillWidth: true
            Layout.bottomMargin: 10 * AppFramework.displayScaleFactor
            implicitHeight: 30 * AppFramework.displayScaleFactor
            visible: false
            RowLayout{
                anchors.fill: parent
                spacing:0
                Button{
                    Layout.preferredWidth: parent.width/3
                    Layout.fillHeight: true
                    style: ButtonStyle {
                        background: Rectangle {
                            anchors.fill: parent
                            color: config.buttonStates(control)
                            radius: app.info.properties.mainButtonRadius
                            border.width: (control.enabled) ? app.info.properties.mainButtonBorderWidth : 0
                            border.color: app.info.properties.mainButtonBorderColor
                            Text{
                                text: qsTr("Save To")
                                color: app.info.properties.mainButtonFontColor
                                font.family: notoRegular.name
                                anchors.centerIn: parent
                            }
                        }
                    }
                    onClicked: {
                        folderChooser.folder = currentSaveToLocation !== null ? currentSaveToLocation : AppFramework.resolvedPathUrl(defaultSaveToLocation);
                        folderChooser.open();
                    }
                }
                Rectangle{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: 10 * AppFramework.displayScaleFactor
                    Text{
                        anchors.fill: parent
                        id: saveToLocationFolder
                        text: ""
                        font.pointSize: config.smallFontSizePoint
                        font.family: notoRegular.name
                        fontSizeMode: Text.Fit
                        minimumPointSize: 10
                        verticalAlignment: Text.AlignVCenter
                        color:config.formElementFontColor
                    }

                }
            }
        }

        //----------------------------------------------------------------------

        Rectangle{
            Layout.fillWidth: true
            Layout.preferredHeight: 40 * AppFramework.displayScaleFactor
            color: "#fff"
            visible: exportAndUpload

            RowLayout{
                anchors.fill: parent
                spacing: 0

                RadioButton {
                    id: uploadToPortalCheckbox
                    exclusiveGroup: destinationExclusiveGroup
                    checked: true
                    onCheckedChanged: {
                        uploadToPortal = (checked) ? true : false;
                    }
                }

                Text{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    verticalAlignment: Text.AlignVCenter
                    color: config.formElementFontColor
                    font.pointSize: config.smallFontSizePoint
                    font.family: notoRegular.name
                    text: qsTr("Upload tile package to ArcGIS")
                }
            }
        }

        //----------------------------------------------------------------------

        Rectangle {
            id: uploadToPortalDetailsContainer
            Layout.fillHeight: true
            Layout.fillWidth: true
            color:"#fff"
            opacity: uploadToPortal ? 1 : 0
            enabled: uploadToPortal ? true : false

                ColumnLayout{
                        anchors.fill: parent
                        spacing:0

                        Rectangle{
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30 * AppFramework.displayScaleFactor
                            RowLayout{
                                       id:tpkDescriptionLabels
                                       spacing:0
                                       anchors.fill: parent

                                       Label {
                                           id: tpkDescriptionTextAreaLabel
                                           Layout.fillHeight: true
                                           Layout.preferredWidth: parent.width/2
                                           text: qsTr("Description")
                                           font.pointSize: config.smallFontSizePoint
                                           font.family: notoRegular.name
                                           color: config.mainLabelFontColor
                                           verticalAlignment: Text.AlignVCenter
                                       }
                                       Text {
                                           id: tpkDescriptionCharacterCount
                                           Layout.fillHeight: true
                                           Layout.fillWidth: true
                                           text: "4000"
                                           font.pointSize: config.xSmallFontSizePoint
                                           font.family: notoRegular.name
                                           color: config.mainLabelFontColor
                                           horizontalAlignment: Text.AlignRight
                                           verticalAlignment: Text.AlignVCenter
                                       }
                                   }
                        }

                        //------------------------------------------------------

                        TextArea {
                            id: tpkDescriptionTextArea
                            Layout.fillWidth: true
                            Layout.preferredHeight: 60 * AppFramework.displayScaleFactor
                            Layout.bottomMargin: 10 * AppFramework.displayScaleFactor
                            property int maximumLength: 4000
                            readOnly: uploadToPortal ? false : true

                            style: TextAreaStyle {
                                backgroundColor: _uiEntryElementStates(control)
                                textColor: config.formElementFontColor
                                font.family: notoRegular.name
                                frame: Rectangle {
                                    border.width: config.formElementBorderWidth
                                    border.color: config.formElementBorderColor
                                    radius: config.formElementRadius
                                    anchors.fill: parent
                                }
                            }
                            onTextChanged: {
                                tpkDescriptionCharacterCount.text =  (maximumLength - text.length).toString();
                                   if (text.length > maximumLength) {
                                       tpkDescriptionTextArea.text = tpkDescriptionTextArea.getText(0, maximumLength);
                                   }
                            }
                        }

                        //------------------------------------------------------

                        Rectangle{
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20 * AppFramework.displayScaleFactor
                            Label {
                                text: qsTr("Share this item with") + ":"
                                font.pointSize: config.smallFontSizePoint
                                font.family: notoRegular.name
                                color: config.mainLabelFontColor
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        //------------------------------------------------------

                        Rectangle {
                            id: tpkSharingContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            ExclusiveGroup {
                                id: sharingExclusiveGroup
                            }

                            RadioButton {
                                id: tpkSharingNotShared
                                exclusiveGroup: sharingExclusiveGroup
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.topMargin: 10 * AppFramework.displayScaleFactor
                                checked: uploadToPortal ? true : false
                                enabled: uploadToPortal ? true : false
                                style: RadioButtonStyle {
                                    indicator: Rectangle {
                                        implicitWidth: 16 * AppFramework.displayScaleFactor
                                        implicitHeight: 16 * AppFramework.displayScaleFactor
                                        radius: 9 * AppFramework.displayScaleFactor
                                        border.width: config.formElementBorderWidth
                                        border.color: config.formElementBorderColor
                                        color: _uiEntryElementStates(control)
                                        Rectangle {
                                            anchors.fill: parent
                                            visible: control.checked
                                            color: config.formElementFontColor
                                            radius: 9 * AppFramework.displayScaleFactor
                                            anchors.margins: 4 * AppFramework.displayScaleFactor
                                        }
                                    }
                                    label: Text{
                                        text: qsTr("Do not share")
                                        font.family: notoRegular.name
                                        color: config.mainLabelFontColor
                                    }
                                }
                                onCheckedChanged: {
                                    if(checked){
                                        currentSharing = "";
                                    }
                                }
                            }

                            RadioButton {
                                id: tpkSharingOrg
                                exclusiveGroup: sharingExclusiveGroup
                                anchors.top: tpkSharingNotShared.bottom
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.topMargin: 8 * AppFramework.displayScaleFactor
                                enabled: uploadToPortal ? true : false
                                style: RadioButtonStyle {
                                    indicator: Rectangle {
                                        implicitWidth: 16 * AppFramework.displayScaleFactor
                                        implicitHeight: 16 * AppFramework.displayScaleFactor
                                        radius: 9 * AppFramework.displayScaleFactor
                                        border.width: config.formElementBorderWidth
                                        border.color: config.formElementBorderColor
                                        color: _uiEntryElementStates(control)
                                        Rectangle {
                                            anchors.fill: parent
                                            visible: control.checked
                                            color: config.formElementFontColor
                                            radius: 9 * AppFramework.displayScaleFactor
                                            anchors.margins: 4 * AppFramework.displayScaleFactor
                                        }
                                    }
                                    label: Text{
                                        text: qsTr("Your organization")
                                        font.family: notoRegular.name
                                        color: config.mainLabelFontColor
                                    }
                                }
                                onCheckedChanged: {
                                    if(checked){
                                        currentSharing = "org";
                                    }
                                }
                            }

                            RadioButton {
                                id: tpkSharingEveryone
                                exclusiveGroup: sharingExclusiveGroup
                                anchors.top: tpkSharingOrg.bottom
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.topMargin: 8 * AppFramework.displayScaleFactor
                                enabled: uploadToPortal ? true : false
                                style: RadioButtonStyle {
                                    indicator: Rectangle {
                                        implicitWidth: 16 * AppFramework.displayScaleFactor
                                        implicitHeight: 16 * AppFramework.displayScaleFactor
                                        radius: 9 * AppFramework.displayScaleFactor
                                        border.width: config.formElementBorderWidth
                                        border.color: config.formElementBorderColor
                                        color: _uiEntryElementStates(control)
                                        Rectangle {
                                            anchors.fill: parent
                                            visible: control.checked
                                            color: config.formElementFontColor
                                            radius: 9 * AppFramework.displayScaleFactor
                                            anchors.margins: 4 * AppFramework.displayScaleFactor
                                        }
                                    }
                                    label: Text{
                                        text: qsTr("Everyone (Public)")
                                        font.family: notoRegular.name
                                        color: config.mainLabelFontColor
                                    }
                                }
                                onCheckedChanged: {
                                    if(checked){
                                        currentSharing = "everyone";
                                    }
                                }
                            }
                        }
                }
        }
    }

    // -------------------------------------------------------------------------

    FileDialog {
        id: folderChooser
        title: "Please choose a folder to save to"
        //selectMultiple: false
        selectFolder: true
        //selectExisting: true
        modality: Qt.WindowModal
        //nameFilters: ["Tile Packages (*.tpk)"]
        onAccepted: {
            //console.log(folderChooser.folder.toString());
            //console.log(folderChooser.fileUrl.toString());
            var folderPath = folderChooser.fileUrl.toString();
            var folderName = _extractFolderDirectory(folderPath); // folderPath.substring(folderPath.lastIndexOf('/'), folderPath.length);
            saveToLocationFolder.text = folderName;
            currentSaveToLocation = AppFramework.resolvedPath(folderChooser.fileUrl);
            folderChooser.close();
        }
        onRejected: {
            currentSaveToLocation = null;
            folderChooser.close();
        }
    }

    // METHODS /////////////////////////////////////////////////////////////////

    function _sanatizeTitle(inText){
        var title = inText.replace(/[^a-zA-Z0-9]/g,"_").toLocaleLowerCase();
        currentExportTitle = title;
        tpkFileTitleName.text = title + "_{uuid}.tpk";
    }

    //--------------------------------------------------------------------------

    function reset(){
        desiredBufferSlider.value = 1;
        desiredLevelsSlider.value = 0;
        uploadToPortalCheckbox.checked = true;
        tpkSharingNotShared.checked = true;
        saveToLocation.checked = false;
        tpkTitleTextField.text = "";
        tpkDescriptionTextArea.text = "";
        currentExportTitle = "";
        currentBufferInMeters = (usesMetric) ? 1 : feetToMeters(1);
    }

    //--------------------------------------------------------------------------

    function _extractFolderDirectory(path){
         return path.substring(path.lastIndexOf('/'), path.length);
    }

    //--------------------------------------------------------------------------

    function _uiEntryElementStates(control){
        if(!control.enabled){
            return config.formElementDisabledBackground;
        }
        else{
            return config.formElementBackground;
        }
    }

    //--------------------------------------------------------------------------

    function localeIsMetric(){
        var locale = Qt.locale();
        switch (locale.measurementSystem) {
            case Locale.ImperialUSSystem:
            case Locale.ImperialUKSystem:
                return false;
            default :
                return true;
        }
    }

    //--------------------------------------------------------------------------

    function feetToMeters(val){
        return Math.ceil(val * 0.3048);
    }

    // END /////////////////////////////////////////////////////////////////////
}
