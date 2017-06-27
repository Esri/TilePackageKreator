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

import QtQml 2.2
import QtQuick 2.7
import QtQuick.Controls 2.1
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
    property int currentBufferInMeters: desiredBufferInput.unitInMeters
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

    onCurrentBufferInMetersChanged: {
        console.log("currentBufferInMeters: ", currentBufferInMeters);
    }

    // UI //////////////////////////////////////////////////////////////////////

    ColumnLayout{
        anchors.fill: parent
        anchors.margins: sf(10)
        spacing: 0

        //----------------------------------------------------------------------

        Rectangle {
            color: "#fff"
            Layout.fillWidth: true
            Layout.preferredHeight: sf(70)
            visible: exportAndUpload
            enabled: exportAndUpload

            ColumnLayout{
                anchors.fill: parent
                spacing:0
                Text {
                    text: qsTr("Number of Zoom Levels")
                    color: config.formElementFontColor
                    font.pointSize: config.smallFontSizePoint
                    font.family: notoRegular
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Accessible.role: Accessible.Heading
                    Accessible.name: text
                }
                Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: sf(50)

                    RowLayout{
                        anchors.fill: parent
                        spacing:0

                        Slider {
                            id: desiredLevelsSlider
                            from: 0
                            to: maxLevels
                            stepSize: 1
                            Layout.fillWidth: true
                            Layout.rightMargin: sf(10)
                            anchors.verticalCenter: parent.verticalCenter

                            onPressedChanged: {
                                if(pressed===false){
                                    tpkDetailsForm.exportZoomLevelsChanged();
                                }
                            }

                            Accessible.role: Accessible.Slider
                            Accessible.name: qsTr("Number of Zoom Levels Slider")
                            Accessible.description: qsTr("This slider allows the user to set the number of desired zoom levels to export from level 0 to the maximum number of levels allowed by the tile service.")
                            Accessible.onPressedChanged: {
                                if(!pressed){
                                    tpkDetailsForm.exportZoomLevelsChanged();
                                }
                            }
                        }

                       TextField {
                            id: desiredLevels
                            Layout.fillHeight: true
                            Layout.preferredWidth: sf(40)
                            readOnly: true
                            text: desiredLevelsSlider.value
                            horizontalAlignment: Text.AlignRight
                            font.pointSize: config.largeFontSizePoint
                            font.family: notoRegular

                            background: Rectangle {
                                anchors.fill: parent
                                border.width: 0
                                radius: 0
                                color: _uiEntryElementStates(parent)
                            }
                            color: config.formElementFontColor
                            Accessible.role: Accessible.StaticText
                            Accessible.name: qsTr("Current number of levels: 0 to %1".arg(desiredLevelsSlider.value.toString()))
                            Accessible.readOnly: true
                            Accessible.description: qsTr("This static text is updated when the slider value is updated.")
                        }
                    }
                }
            }
        }

        //----------------------------------------------------------------------

        StatusIndicator{
            id: levelsWarning
            Layout.fillWidth: true
            Layout.topMargin: sf(5)
            containerHeight: desiredLevelsSlider.value > 15 ? sf(30) : sf(1)
            statusTextFontSize: config.xSmallFontSizePoint
            messageType: warning
            message: qsTr("Export may fail with this many levels if extent is too large.")
            visible: (exportAndUpload && desiredLevelsSlider.value) > 15 ? true : false
            statusTextObject.anchors.margins: sf(10)
            statusTextObject.wrapMode: Text.Wrap

            Accessible.role: Accessible.AlertMessage
            Accessible.name: message
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: sf(1)
            Layout.topMargin: sf(5)
            color: config.subtleBackground
            visible: exportAndUpload
            Accessible.ignored: true
        }

        //----------------------------------------------------------------------

        Rectangle {
            color: "#fff"
            Layout.fillWidth: true
            Layout.preferredHeight: sf(70)
            Layout.topMargin: sf(10)
            visible: exportAndUpload && exportPathBuffering
            enabled: exportAndUpload && exportPathBuffering

            ColumnLayout{
                anchors.fill: parent
                spacing:0
                Text {
                    text: qsTr("Buffer Radius")
                    color: config.formElementFontColor
                    font.pointSize: config.smallFontSizePoint
                    font.family: notoRegular
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Accessible.role: Accessible.Heading
                    Accessible.name: text
                }
                Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: sf(50)

                    RowLayout{
                        anchors.fill: parent
                        spacing:0

                        TextField {
                            id: desiredBufferInput
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.rightMargin: sf(10)

                            property int unitInMeters: 1

                            placeholderText: "%1 max, [default=1]".arg(distanceUnits.get(desiredBufferDistanceUnit.currentIndex).max.toString())

                            validator: IntValidator { bottom: 1; top: distanceUnits.get(desiredBufferDistanceUnit.currentIndex).max;}

                            background: Rectangle {
                                anchors.fill: parent
                                border.width: config.formElementBorderWidth
                                border.color: config.formElementBorderColor
                                radius: config.formElementRadius
                                color: _uiEntryElementStates(parent)
                            }
                            color: config.formElementFontColor
                            font.family: notoRegular

                            onTextChanged: {
                                currentBufferInMeters = (text !== "") ? Math.ceil(text * distanceUnits.get(desiredBufferDistanceUnit.currentIndex).conversionFactor) : 1;
                            }

                            Accessible.role: Accessible.EditableText
                            Accessible.name: qsTr("Enter a buffer radius.")
                            Accessible.focusable: true
                        }

                        ComboBox {
                            id: desiredBufferDistanceUnit
                            Layout.fillHeight: true
                            //Layout.fillWidth: true
                            Layout.preferredWidth: sf(50)

                            currentIndex: usesMetric ? 0 : 2
                            textRole: "text"

                            model: ListModel {
                                 id: distanceUnits
                                ListElement { text: "m"; max: 3000; conversionFactor: 1 }
                                ListElement { text: "km"; max: 5; conversionFactor: 1000}
                                ListElement { text: "ft"; max: 4000; conversionFactor: 0.3048 }
                                ListElement { text: "mi"; max: 5; conversionFactor: 1609.34 }
                            }

                            onCurrentIndexChanged: {
                                desiredBufferInput.text = "";
                            }
                        }

                        /*
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

                            Accessible.role: Accessible.Slider
                            Accessible.name: qsTr("Buffer Radius Slider")
                            Accessible.description: qsTr("This slider allows the user to set the desired buffer radius around a drawn multi point path.")
                            Accessible.onPressedChanged: {
                                if(!pressed){
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
                                font.family: notoRegular
                            }
                            Accessible.role: Accessible.StaticText
                            Accessible.name: qsTr("Current buffer radius is %1".arg(text))
                            Accessible.readOnly: true
                            Accessible.description: qsTr("This static text is updated when the buffer radius slider value is updated.")
                        }
                        */
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: sf(1)
            Layout.topMargin: sf(5)
            color: config.subtleBackground
            visible: exportAndUpload && exportPathBuffering
            Accessible.ignored: true
        }

        //----------------------------------------------------------------------

        ButtonGroup { id: destinationExclusiveGroup }

        //----------------------------------------------------------------------

        Rectangle{
            Layout.fillWidth: true
            Layout.preferredHeight: sf(30)
            color:"#fff"

            RowLayout{
                id: tpkTitleLabels
                anchors.fill: parent
                spacing:0

                Label {
                    id: tpkTitleTextFieldLabel
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: qsTr("Title") + "<span style=\"color:red\"> *</span>"
                    textFormat: Text.RichText
                    font.pointSize: config.smallFontSizePoint
                    font.family: notoRegular
                    color: config.mainLabelFontColor
                    verticalAlignment: Text.AlignVCenter

                    Accessible.role: Accessible.Heading
                    Accessible.name: text
                }
            }
         }

         Rectangle{
             Layout.fillWidth: true
             Layout.preferredHeight: sf(40)
             Layout.bottomMargin: sf(5)

            TextField {
                id: tpkTitleTextField
                anchors.fill: parent
                placeholderText: qsTr("Enter a title")

                background: Rectangle {
                    anchors.fill: parent
                    border.width: config.formElementBorderWidth
                    border.color: config.formElementBorderColor
                    radius: config.formElementRadius
                    color: _uiEntryElementStates(parent)
                }
                color: config.formElementFontColor
                font.family: notoRegular

                onTextChanged: {
                    if(tpkTitleTextField.length > 0){
                        _sanatizeTitle(text);
                    }
                    else{
                        tpkFileTitleName.text = "";
                        currentExportTitle = "";
                    }
                }

                Accessible.role: Accessible.EditableText
                Accessible.name: qsTr("Enter a title for the exported tile package.")
                Accessible.focusable: true
            }
        }

        Rectangle{
            Layout.fillWidth:true
            Layout.preferredHeight: sf(10)
            Layout.bottomMargin: sf(5)
            visible: false
            Accessible.ignored: true
            Text{
                id: tpkFileTitleName
                anchors.fill: parent
                font.pointSize: config.xSmallFontSizePoint
                font.family: notoRegular
                color: config.formElementFontColor
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: config.subtleBackground
            visible: exportAndUpload
            Accessible.ignored: true
        }

        //----------------------------------------------------------------------

        Rectangle{
            Layout.fillWidth: true
            Layout.preferredHeight: sf(40)
            color:"#fff"
            visible: exportAndUpload
            enabled: exportAndUpload

            RowLayout{
                anchors.fill: parent
                spacing: 0

                RadioButton {
                    id: saveToLocation
                    ButtonGroup.group: destinationExclusiveGroup
                    onCheckedChanged: {
                        currentSaveToLocation = (dlr.saveToPath !== null) ? defaultSaveToLocation : null;
                        saveToLocationFolder.text = _extractFolderDirectory(defaultSaveToLocation);
                        saveToLocationDetails.visible = this.checked;
                    }

                    Accessible.role: Accessible.RadioButton
                    Accessible.name: qsTr(saveToLocationLabel.text)
                }

                Text{
                    id: saveToLocationLabel
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    verticalAlignment: Text.AlignVCenter
                    color: config.formElementFontColor
                    font.pointSize: config.smallFontSizePoint
                    font.family: notoRegular
                    text: qsTr("Save tile package locally")
                    Accessible.ignored: true
                }
            }
        }

        Rectangle{
            id: saveToLocationDetails
            color:"#fff"
            Layout.fillWidth: true
            Layout.bottomMargin: sf(10)
            implicitHeight: sf(30)
            visible: false
            RowLayout{
                anchors.fill: parent
                spacing:0
                Button{
                    Layout.preferredWidth: parent.width/3
                    Layout.fillHeight: true
                    background: Rectangle {
                        anchors.fill: parent
                        color: config.buttonStates(parent)
                        radius: app.info.properties.mainButtonRadius
                        border.width: parent.enabled ? app.info.properties.mainButtonBorderWidth : 0
                        border.color: app.info.properties.mainButtonBorderColor
                        Text{
                            text: qsTr("Save To")
                            color: app.info.properties.mainButtonFontColor
                            font.family: notoRegular
                            anchors.centerIn: parent
                        }
                    }
                    onClicked: {
                        folderChooser.folder = currentSaveToLocation !== null ? currentSaveToLocation : AppFramework.resolvedPathUrl(defaultSaveToLocation);
                        folderChooser.open();
                    }

                    Accessible.role: Accessible.Button
                    Accessible.name: qsTr("Select the location to save the tile package to locally.")
                    Accessible.description: qsTr("This button will open a file dialog chooser that allows the user to select the folder to save the tile package to locally.")
                    Accessible.onPressAction: {
                        if(saveToLocationDetails.visible){
                            clicked();
                        }
                    }
                }
                Rectangle{
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: sf(10)
                    Text{
                        anchors.fill: parent
                        id: saveToLocationFolder
                        text: ""
                        font.pointSize: config.smallFontSizePoint
                        font.family: notoRegular
                        fontSizeMode: Text.Fit
                        minimumPointSize: 10
                        verticalAlignment: Text.AlignVCenter
                        color:config.formElementFontColor

                        Accessible.role: Accessible.StaticText
                        Accessible.name: qsTr("Selected save to location: %1".arg(text))
                    }
                }
            }
        }

        //----------------------------------------------------------------------

        Rectangle{
            Layout.fillWidth: true
            Layout.preferredHeight: sf(40)
            color: "#fff"
            visible: exportAndUpload

            RowLayout{
                anchors.fill: parent
                spacing: 0

                RadioButton {
                    id: uploadToPortalCheckbox
                    ButtonGroup.group: destinationExclusiveGroup
                    checked: true
                    onCheckedChanged: {
                        uploadToPortal = (checked) ? true : false;
                    }

                    Accessible.role: Accessible.RadioButton
                    Accessible.name: qsTr(uploadToPortalCheckboxLabel.text)
                }

                Text{
                    id: uploadToPortalCheckboxLabel
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    verticalAlignment: Text.AlignVCenter
                    color: config.formElementFontColor
                    font.pointSize: config.smallFontSizePoint
                    font.family: notoRegular
                    text: qsTr("Upload tile package to ArcGIS")
                    Accessible.ignored: true
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
                            Layout.preferredHeight: sf(30)
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
                                           font.family: notoRegular
                                           color: config.mainLabelFontColor
                                           verticalAlignment: Text.AlignVCenter
                                           Accessible.role: Accessible.Heading
                                           Accessible.name: text
                                       }
                                       Text {
                                           id: tpkDescriptionCharacterCount
                                           Layout.fillHeight: true
                                           Layout.fillWidth: true
                                           text: "4000"
                                           font.pointSize: config.xSmallFontSizePoint
                                           font.family: notoRegular
                                           color: config.mainLabelFontColor
                                           horizontalAlignment: Text.AlignRight
                                           verticalAlignment: Text.AlignVCenter
                                           Accessible.role: Accessible.AlertMessage
                                           Accessible.name: text
                                           Accessible.description: qsTr("This text displays the number of charcters left available in the description text area.")
                                       }
                                   }
                        }

                        //------------------------------------------------------

                        TextArea {
                            id: tpkDescriptionTextArea
                            Layout.fillWidth: true
                            Layout.preferredHeight: sf(60)
                            Layout.bottomMargin: sf(10)
                            property int maximumLength: 4000
                            readOnly: uploadToPortal ? false : true

                            color: config.formElementFontColor
                            font.family: notoRegular
                            background: Rectangle {
                                color: _uiEntryElementStates(parent)
                                border.width: config.formElementBorderWidth
                                border.color: config.formElementBorderColor
                                radius: config.formElementRadius
                                anchors.fill: parent
                            }

                            onTextChanged: {
                                tpkDescriptionCharacterCount.text =  (maximumLength - text.length).toString();
                                   if (text.length > maximumLength) {
                                       tpkDescriptionTextArea.text = tpkDescriptionTextArea.getText(0, maximumLength);
                                   }
                            }

                            Accessible.role: Accessible.EditableText
                            Accessible.name: qsTr("Tile package description text area entry")
                            Accessible.description: qsTr("Enter a description of the tile package for the online item.")
                        }

                        //------------------------------------------------------

                        Rectangle{
                            Layout.fillWidth: true
                            Layout.preferredHeight: sf(20)
                            Label {
                                text: qsTr("Share this item with:")
                                font.pointSize: config.smallFontSizePoint
                                font.family: notoRegular
                                color: config.mainLabelFontColor
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter

                                Accessible.role: Accessible.Heading
                                Accessible.name: text
                            }
                        }

                        //------------------------------------------------------

                        Rectangle {
                            id: tpkSharingContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            ButtonGroup {
                                id: sharingExclusiveGroup
                            }

                            RadioButton {
                                id: tpkSharingNotShared
                                ButtonGroup.group: sharingExclusiveGroup
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.topMargin: sf(10)
                                checked: uploadToPortal ? true : false
                                enabled: uploadToPortal ? true : false
                                indicator: Rectangle {
                                    implicitWidth: sf(16)
                                    implicitHeight: sf(16)
                                    x: 0
                                    y: parent.height / 2 - height / 2
                                    radius: sf(8)
                                    border.width: config.formElementBorderWidth
                                    border.color: config.formElementBorderColor
                                    color: _uiEntryElementStates(parent)
                                    Rectangle {
                                        anchors.fill: parent
                                        visible: parent.parent.checked
                                        color: config.formElementFontColor
                                        radius: sf(9)
                                        anchors.margins: sf(4)
                                    }
                                }
                                contentItem: Text{
                                    text: qsTr("Do not share")
                                    font.family: notoRegular
                                    color: config.mainLabelFontColor
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: tpkSharingNotShared.indicator.width + sf(5)
                                }

                                onCheckedChanged: {
                                    if(checked){
                                        currentSharing = "";
                                    }
                                }
                                Accessible.role: Accessible.RadioButton
                                Accessible.name: qsTr("Do not share")
                            }

                            RadioButton {
                                id: tpkSharingOrg
                                ButtonGroup.group: sharingExclusiveGroup
                                anchors.top: tpkSharingNotShared.bottom
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.topMargin: sf(8)
                                enabled: uploadToPortal ? true : false
                                indicator: Rectangle {
                                    implicitWidth: sf(16)
                                    implicitHeight: sf(16)
                                    x: 0
                                    y: parent.height / 2 - height / 2
                                    radius: sf(8)
                                    border.width: config.formElementBorderWidth
                                    border.color: config.formElementBorderColor
                                    color: _uiEntryElementStates(parent)
                                    Rectangle {
                                        anchors.fill: parent
                                        visible: parent.parent.checked
                                        color: config.formElementFontColor
                                        radius: sf(9)
                                        anchors.margins: sf(4)
                                    }
                                }
                                contentItem: Text{
                                    text: qsTr("Your organization")
                                    font.family: notoRegular
                                    color: config.mainLabelFontColor
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: tpkSharingOrg.indicator.width + sf(5)
                                }

                                onCheckedChanged: {
                                    if(checked){
                                        currentSharing = "org";
                                    }
                                }
                                Accessible.role: Accessible.RadioButton
                                Accessible.name: qsTr("Your organization")
                            }

                            RadioButton {
                                id: tpkSharingEveryone
                                ButtonGroup.group: sharingExclusiveGroup
                                anchors.top: tpkSharingOrg.bottom
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.topMargin: sf(8)
                                enabled: uploadToPortal ? true : false
                                indicator: Rectangle {
                                    implicitWidth: sf(16)
                                    implicitHeight: sf(16)
                                    x: 0
                                    y: parent.height / 2 - height / 2
                                    radius: sf(8)
                                    border.width: config.formElementBorderWidth
                                    border.color: config.formElementBorderColor
                                    color: _uiEntryElementStates(parent)
                                    Rectangle {
                                        anchors.fill: parent
                                        visible: parent.parent.checked
                                        color: config.formElementFontColor
                                        radius: sf(9)
                                        anchors.margins: sf(4)
                                    }
                                }
                                contentItem: Text{
                                    text: qsTr("Everyone (Public)")
                                    font.family: notoRegular
                                    color: config.mainLabelFontColor
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: tpkSharingEveryone.indicator.width + sf(5)
                                }

                                onCheckedChanged: {
                                    if(checked){
                                        currentSharing = "everyone";
                                    }
                                }
                                Accessible.role: Accessible.RadioButton
                                Accessible.name: qsTr("Everyone (Public)")
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
        //desiredBufferSlider.value = 1;
        desiredLevelsSlider.value = 0;
        desiredBufferInput.text = "";
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
