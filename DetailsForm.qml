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

import QtQml 2.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import QtLocation 5.15
import QtPositioning 5.15
import QtGraphicalEffects 1.12
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import "singletons" as Singletons
import "Controls" as Controls
//------------------------------------------------------------------------------

Rectangle {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: tpkDetailsForm

    property int maxLevels: 21
    property string currentSharing: ""
    property string currentExportTitle: ""
    property var currentTileService: null
    property var currentLevels: null
    property var currentExportRequest: ({})
    property var currentSaveToLocation: null
    property int currentBufferInMeters: desiredBufferInput.unitInMeters
    property string defaultSaveToLocation: ""

    property ListModel tileServicesSimpleListModel
    property int currentTileIndex: 0

    property bool exportAndUpload: true
    property bool exportOnly: false
    property bool uploadOnly: false
    property bool exportPathBuffering: false
    property bool uploadToPortal: true
    property bool usesMetric: localeIsMetric()

    readonly property string kOrgSharing: "org"
    readonly property string kPublicSharing: "everyone"

    property int lastKnownBottomZoomLevel
    property int lastKnownTopZoomLevel

    property alias tpkZoomLevels: desiredLevelsSlider.second
    property alias tpkBottomZoomLevel: desiredLevelsSlider.first
    property alias tpkTopZoomLevel: desiredLevelsSlider.second
    property alias tpkTitle: tpkTitleTextField.text
    //property alias tpkSharing: tpkDetailsForm.currentSharing
    property alias tpkDescription: tpkDescriptionTextArea.text
    property alias exportToFolder: folderChooser.folder

    signal exportZoomLevelsChanged()
    signal exportBufferDistanceChanged()
    signal changeTileService(int index)

    // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////////

    Component.onCompleted: {
        currentBufferInMeters = (usesMetric) ? 1 : feetToMeters(1);
    }

    //--------------------------------------------------------------------------

    onExportBufferDistanceChanged: {
        currentBufferInMeters = (usesMetric) ? desiredBufferSlider.value : feetToMeters(desiredBufferSlider.value);
    }

    onCurrentBufferInMetersChanged: {
        console.log("currentBufferInMeters: ", currentBufferInMeters);
    }

    onMaxLevelsChanged: {
        desiredLevelsSlider.to = maxLevels;
        desiredLevelsSlider.first.value = 0;
        desiredLevelsSlider.second.value = 3;
    }

    // UI //////////////////////////////////////////////////////////////////////

    Flickable {
        id: details
        width: parent.width
        height: parent.height
        contentWidth: parent.width
        interactive: true
        flickableDirection: Flickable.VerticalFlick
        clip: true
        Accessible.role: Accessible.Pane

        Connections {
            target: bufferRadiusContainer

            function onVisibleChanged() {
                if (bufferRadiusContainer.visible) {
                    details.contentHeight += bufferRadiusContainer.controlHeight;
                }
                else {
                    details.contentHeight -= bufferRadiusContainer.controlHeight;
                }
            }
        }

        ColumnLayout{
            id: detailsControls
            anchors.fill: parent
            anchors.margins: sf(10)
            spacing: 0

            onHeightChanged: {
                console.log("onHeightChanged")
                _setDetailFormHeight();
            }

            Component.onCompleted: {
                console.log("Component.onCompleted")
                _setDetailFormHeight();
            }

            //------------------------------------------------------------------

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: sf(70)
                visible: exportOnly
                enabled: exportOnly

                ColumnLayout{
                    anchors.fill: parent
                    spacing: 0

                    Text {
                        text: Singletons.Strings.currentTileService
                        color: Singletons.Colors.darkGray
                        font.pointSize: Singletons.Config.smallFontSizePoint
                        font.family: defaultFontFamily
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Accessible.role: Accessible.Heading
                        Accessible.name: text
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: sf(40)
                        Controls.StyledComboBox {
                            anchors.fill: parent
                            model: tileServicesSimpleListModel
                            textRole: "title"
                            currentIndex: currentTileIndex

                            onCurrentIndexChanged: {
                                currentTileIndex = currentIndex;
                                changeTileService(currentTileIndex);
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: sf(2)
                Layout.topMargin: sf(8)
                Layout.bottomMargin: sf(8)
                color: Singletons.Colors.mediumGray
                visible: exportAndUpload
                Accessible.ignored: true
            }

            Item {
                objectName: "one"
                Layout.fillWidth: true
                Layout.preferredHeight: sf(70)
                visible: exportAndUpload
                enabled: exportAndUpload

                ColumnLayout{
                    anchors.fill: parent
                    spacing: 0

                    Text {
                        text: Singletons.Strings.numberOfZoomLevels
                        color: Singletons.Colors.darkGray
                        font.pointSize: Singletons.Config.smallFontSizePoint
                        font.family: defaultFontFamily
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Accessible.role: Accessible.Heading
                        Accessible.name: text
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: sf(50)

                        RowLayout{
                            anchors.fill: parent
                            spacing:0

                            Controls.StyledRangeSlider {
                                id: desiredLevelsSlider
                                Layout.fillWidth: true
                                Layout.rightMargin: sf(10)
                                from: 0
                                to: maxLevels
                                stepSize: 1
                                snapMode: RangeSlider.SnapAlways
                                first.value: 0
                                second.value: 3
                            }

                            Connections {
                                target: desiredLevelsSlider.second
                                function onValueChanged() {
                                    tpkDetailsForm.exportZoomLevelsChanged();
                                }
                            }

                            Connections {
                                target: desiredLevelsSlider.first
                                function onValueChanged() {
                                    tpkDetailsForm.exportZoomLevelsChanged();
                                }
                            }

                            Text {
                                id: desiredLevels
                                Layout.fillHeight: true
                                Layout.preferredWidth: sf(50)
                                text: "%1 - %2".arg(desiredLevelsSlider.first.value).arg(desiredLevelsSlider.second.value);
                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignVCenter
                                font.pointSize: Singletons.Config.mediumFontSizePoint
                                font.family: defaultFontFamily
                                color: Singletons.Colors.darkGray

                                Accessible.role: Accessible.StaticText
                                Accessible.name: Singletons.Strings.desiredLevelsDesc
                                Accessible.readOnly: true
                                Accessible.description: Singletons.Strings.desiredLevelsDesc
                            }
                        }
                    }
                }
            }

            //----------------------------------------------------------------------

            StatusIndicator{
                objectName: "levelsWarning"
                id: levelsWarning
                Layout.fillWidth: true
                Layout.topMargin: sf(5)
                containerHeight: desiredLevelsSlider.second.value > 15 ? sf(38) : sf(1)
                statusTextFontSize: Singletons.Config.xSmallFontSizePoint
                narrowLineHeight: true
                messageType: warning
                message: Singletons.Strings.exportMayFailWarning
                visible: (exportAndUpload && desiredLevelsSlider.second.value > 15) ? true : false
                statusTextObject.anchors.margins: sf(10)
                statusTextObject.wrapMode: Text.Wrap

                Accessible.role: Accessible.AlertMessage
                Accessible.name: message
            }

            Rectangle {
                objectName: "spacer"
                Layout.fillWidth: true
                Layout.preferredHeight: sf(2)
                Layout.topMargin: sf(8)
                Layout.bottomMargin: sf(8)
                color: Singletons.Colors.mediumGray
                visible: exportAndUpload
                Accessible.ignored: true
            }

            //----------------------------------------------------------------------

            Rectangle {
                objectName: "bufferRadiusContainer"
                id: bufferRadiusContainer
                property int controlHeight: sf(70)
                color: "#fff"
                Layout.fillWidth: true
                Layout.preferredHeight: controlHeight
                visible: exportAndUpload && exportPathBuffering
                enabled: exportAndUpload && exportPathBuffering

                ColumnLayout{
                    anchors.fill: parent
                    spacing:0

                    Text {
                        text: Singletons.Strings.bufferRadius
                        color: Singletons.Colors.darkGray
                        font.pointSize: Singletons.Config.smallFontSizePoint
                        font.family: defaultFontFamily
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Accessible.role: Accessible.Heading
                        Accessible.name: text
                    }

                    Rectangle{
                        Layout.fillWidth: true
                        Layout.preferredHeight: sf(40)

                        RowLayout{
                            anchors.fill: parent
                            spacing:0

                            Controls.StyledTextField {
                                id: desiredBufferInput
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Layout.rightMargin: sf(10)
                                property int unitInMeters: 1

                                placeholderText: "%1 max, [default=1]".arg(distanceUnits.get(desiredBufferDistanceUnit.currentIndex).max.toString())
                                validator: IntValidator { bottom: 1; top: distanceUnits.get(desiredBufferDistanceUnit.currentIndex).max;}
                                onTextChanged: {
                                    currentBufferInMeters = (text !== "") ? Math.ceil(text * distanceUnits.get(desiredBufferDistanceUnit.currentIndex).conversionFactor) : 1;
                                }

                                Accessible.role: Accessible.EditableText
                                Accessible.name: Singletons.Strings.bufferRadiusDesc
                                Accessible.focusable: true
                            }

                            Controls.StyledComboBox {
                                id: desiredBufferDistanceUnit
                                Layout.fillHeight: true
                                Layout.preferredWidth: sf(80)

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
                        }
                    }
                }
            }

            Rectangle {
                objectName: "spacer"
                Layout.fillWidth: true
                Layout.preferredHeight: sf(2)
                Layout.topMargin: sf(8)
                Layout.bottomMargin: sf(8)
                color: Singletons.Colors.mediumGray
                visible: exportAndUpload && exportPathBuffering
                Accessible.ignored: true
            }

            //----------------------------------------------------------------------

            ButtonGroup { id: destinationExclusiveGroup }

            //----------------------------------------------------------------------

            Rectangle{
                objectName: "tpkTitleLabels"

                Layout.fillWidth: true
                Layout.preferredHeight: sf(30)
                color:"#fff"

                RowLayout{
                    id: tpkTitleLabels
                    anchors.fill: parent
                    spacing: 0

                    Label {
                        id: tpkTitleTextFieldLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        text: Singletons.Strings.title + "<span style=\"color:red\"> *</span>"
                        textFormat: Text.RichText
                        font.pointSize: Singletons.Config.smallFontSizePoint
                        font.family: defaultFontFamily
                        color: Singletons.Colors.darkGray
                        verticalAlignment: Text.AlignVCenter

                        Accessible.role: Accessible.Heading
                        Accessible.name: text
                    }
                }
             }

             Rectangle{
                 objectName: "tpkTitleTextField"

                 Layout.fillWidth: true
                 Layout.preferredHeight: sf(40)
                 Layout.bottomMargin: sf(5)

                 Controls.StyledTextField {
                     id: tpkTitleTextField
                     anchors.fill: parent
                     placeholderText: Singletons.Strings.enterATitle
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
                     Accessible.name: Singletons.Strings.enterATitle
                     Accessible.focusable: true
                 }
            }

            Rectangle {
                objectName: "tpkFileTitleName"

                Layout.fillWidth: true
                Layout.preferredHeight: sf(10)
                visible: false
                Accessible.ignored: true
                Text {
                    id: tpkFileTitleName
                    anchors.fill: parent
                    font.pointSize: Singletons.Config.xSmallFontSizePoint
                    font.family: defaultFontFamily
                    color: Singletons.Colors.formElementFontColor
                }
            }

            Rectangle {
                objectName: "spacer"
                Layout.fillWidth: true
                Layout.preferredHeight: sf(2)
                Layout.topMargin: sf(8)
                Layout.bottomMargin: sf(8)
                color: Singletons.Colors.mediumGray
                visible: exportAndUpload
                Accessible.ignored: true
            }

            //----------------------------------------------------------------------

            Text {
                objectName: "Save_To"

                text: Singletons.Strings.saveTo //qsTr("Save To")
                color: Singletons.Colors.darkGray
                font.pointSize: Singletons.Config.smallFontSizePoint
                font.family: defaultFontFamily
                Layout.fillWidth: true
                Layout.preferredHeight: sf(20)
                Accessible.role: Accessible.Heading
                Accessible.name: text
                visible: exportOnly
            }

            Item {
                objectName: "saveToLocationRadioButton"

                Layout.fillWidth: true
                Layout.preferredHeight: sf(40)
                visible: exportAndUpload
                enabled: exportAndUpload

                Controls.StyledRadioButton {
                    id: saveToLocationRadioButton
                    height: sf(20)
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    text: Singletons.Strings.saveTpkLocally
                    ButtonGroup.group: destinationExclusiveGroup
                    onCheckedChanged: {
                        currentSaveToLocation = (dlr.saveToPath !== null) ? defaultSaveToLocation : null;
                        saveToLocationFolder.text = _extractFolderDirectory(defaultSaveToLocation);
                        saveToLocationDetails.visible = this.checked;
                    }

                    Accessible.role: Accessible.RadioButton
                    Accessible.name: qsTr(saveToLocationRadioButton.text)
                }
            }

            Rectangle {
                objectName: "saveToLocationDetails"

                id: saveToLocationDetails
                Layout.fillWidth: true
                Layout.bottomMargin: sf(10)
                Layout.leftMargin: uploadOnly ? 0 : sf(20)
                color: uploadOnly ? "white" : Singletons.Colors.lightGray
                implicitHeight: sf(40)
                visible: false

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: sf(5)
                    spacing: 0

                    Button {
                        Layout.preferredWidth: parent.width / 3
                        Layout.fillHeight: true
                        background: Rectangle {
                            anchors.fill: parent
                            color: Singletons.Config.buttonStates(parent)
                            radius: app.info.properties.mainButtonRadius
                            border.width: parent.enabled ? app.info.properties.mainButtonBorderWidth : 0
                            border.color: app.info.properties.mainButtonBorderColor
                            Text {
                                text: Singletons.Strings.saveTo
                                color: app.info.properties.mainButtonFontColor
                                font.family: defaultFontFamily
                                anchors.centerIn: parent
                            }
                        }
                        onClicked: {
                            folderChooser.folder = currentSaveToLocation !== null
                                                    ? currentSaveToLocation
                                                    : AppFramework.resolvedPathUrl(defaultSaveToLocation);
                            folderChooser.open();
                        }

                        Accessible.role: Accessible.Button
                        Accessible.name: Singletons.Strings.saveTo
                        Accessible.description: Singletons.Strings.saveToDesc
                        Accessible.onPressAction: {
                            if(saveToLocationDetails.visible){
                                clicked();
                            }
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.leftMargin: sf(10)
                        Text {
                            anchors.fill: parent
                            id: saveToLocationFolder
                            text: ""
                            font.pointSize: Singletons.Config.smallFontSizePoint
                            font.family: defaultFontFamily
                            fontSizeMode: Text.Fit
                            minimumPointSize: 10
                            verticalAlignment: Text.AlignVCenter
                            color: Singletons.Colors.formElementFontColor

                            Accessible.role: Accessible.StaticText
                            Accessible.name: Singletons.Strings.saveToLocationDesc
                        }
                    }
                }
            }

            //----------------------------------------------------------------------

            Rectangle {
                objectName: "uploadToPortalRadioButton"

                Layout.fillWidth: true
                Layout.preferredHeight: sf(40)
                color: "#fff"
                visible: exportAndUpload

                Controls.StyledRadioButton {
                    id: uploadToPortalRadioButton
                    height: sf(20)
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    text: Singletons.Strings.uploadToArcGIS
                    ButtonGroup.group: destinationExclusiveGroup
                    checked: true
                    onCheckedChanged: {
                        uploadToPortal = (checked) ? true : false;
                    }

                    Accessible.role: Accessible.RadioButton
                    Accessible.name: qsTr(uploadToPortalRadioButton.text)
                }
            }

            //----------------------------------------------------------------------

            Rectangle {
                objectName: "uploadToPortalDetailsContainer"

                id: uploadToPortalDetailsContainer
                //Layout.fillHeight: true
                Layout.preferredHeight: sf(265)
                Layout.fillWidth: true
                Layout.leftMargin: uploadOnly ? 0 : sf(20)
                color: uploadOnly ? "white" : Singletons.Colors.lightGray
                opacity: uploadToPortal ? 1 : 0
                enabled: uploadToPortal ? true : false

                ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: uploadOnly ? 0 : sf(5)
                        spacing:0

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: sf(30)

                            RowLayout {
                               id: tpkDescriptionLabels
                               spacing: 0
                               anchors.fill: parent

                               Label {
                                   id: tpkDescriptionTextAreaLabel
                                   Layout.fillHeight: true
                                   Layout.preferredWidth: parent.width/2
                                   text: Singletons.Strings.description
                                   font.pointSize: Singletons.Config.smallFontSizePoint
                                   font.family: defaultFontFamily
                                   color: Singletons.Colors.darkGray
                                   verticalAlignment: Text.AlignVCenter
                                   Accessible.role: Accessible.Heading
                                   Accessible.name: text
                               }

                               Text {
                                   id: tpkDescriptionCharacterCount
                                   Layout.fillHeight: true
                                   Layout.fillWidth: true
                                   text: "4000"
                                   font.pointSize: Singletons.Config.xSmallFontSizePoint
                                   font.family: defaultFontFamily
                                   color: Singletons.Colors.darkGray
                                   horizontalAlignment: Text.AlignRight
                                   verticalAlignment: Text.AlignVCenter
                                   Accessible.role: Accessible.AlertMessage
                                   Accessible.name: text
                                   Accessible.description: Singletons.Strings.descriptionCharCountDesc
                               }
                           }
                        }

                        //------------------------------------------------------

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: sf(70)


                            ScrollView {
                                id: views
                                anchors.fill: parent
                                ScrollBar.horizontal.policy: Qt.ScrollBarAlwaysOff
                                ScrollBar.vertical.policy: Qt.ScrollBarAsNeeded
                                TextArea {
                                    id: tpkDescriptionTextArea
                                    height: sf(200)
                                    width: views.width - sf(15)
                                    property int maximumLength: 4000
                                    readOnly: uploadToPortal ? false : true
                                    selectByMouse: true
                                    wrapMode: Text.Wrap

                                    color: Singletons.Colors.formElementFontColor
                                    font.family: defaultFontFamily
                                    font.pointSize: Singletons.Config.xSmallFontSizePoint
                                    background: Rectangle {
                                        color: _uiEntryElementStates(parent)
                                        border.width: Singletons.Config.formElementBorderWidth
                                        border.color: Singletons.Colors.formElementBorderColor
                                        radius: Singletons.Config.formElementRadius
                                        anchors.fill: parent
                                    }

                                    onTextChanged: {
                                        tpkDescriptionCharacterCount.text = (maximumLength - text.length).toString();
                                           if (text.length > maximumLength) {
                                               tpkDescriptionTextArea.text = tpkDescriptionTextArea.getText(0, maximumLength);
                                           }
                                    }

                                    Accessible.role: Accessible.EditableText
                                    Accessible.name: Singletons.Strings.descriptionTextAreaDesc
                                    Accessible.description: Singletons.Strings.descriptionTextAreaDesc
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: sf(1)
                            Layout.bottomMargin: sf(10)
                            color: Singletons.Colors.formElementBorderColor
                        }

                        //------------------------------------------------------

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: sf(30)
                            Label {
                                text: Singletons.Strings.shareThisItemWith
                                font.pointSize: Singletons.Config.smallFontSizePoint
                                font.family: defaultFontFamily
                                color: Singletons.Colors.mainLabelFontColor
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter

                                Accessible.role: Accessible.Heading
                                Accessible.name: text
                            }
                        }

                        //------------------------------------------------------

                        Item {
                            id: tpkSharingContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            ButtonGroup {
                                id: sharingExclusiveGroup
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: sf(5)

                                Item {
                                    Layout.preferredHeight: sf(20)
                                    Layout.fillWidth: true
                                    Controls.StyledRadioButton {
                                        id: tpkSharingNotShared
                                        anchors.fill: parent
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: Singletons.Strings.doNotShare
                                        ButtonGroup.group: sharingExclusiveGroup
                                        checked: uploadToPortal ? true : false
                                        enabled: uploadToPortal ? true : false
                                        onCheckedChanged: {
                                            if(checked){
                                                currentSharing = "";
                                            }
                                        }
                                        Accessible.role: Accessible.RadioButton
                                        Accessible.name: Singletons.Strings.doNotShare
                                    }
                                }

                                Item {
                                    Layout.preferredHeight: sf(20)
                                    Layout.fillWidth: true
                                    Controls.StyledRadioButton {
                                        anchors.fill: parent
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: Singletons.Strings.yourOrg
                                        ButtonGroup.group: sharingExclusiveGroup
                                        enabled: uploadToPortal ? true : false
                                        onCheckedChanged: {
                                            if(checked){
                                                currentSharing = kOrgSharing;
                                            }
                                        }
                                        Accessible.role: Accessible.RadioButton
                                        Accessible.name: Singletons.Strings.yourOrg
                                    }
                                }


                                Item {
                                    Layout.preferredHeight: sf(20)
                                    Layout.fillWidth: true
                                    Controls.StyledRadioButton {
                                        anchors.fill: parent
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: Singletons.Strings.everyonePublic
                                        ButtonGroup.group: sharingExclusiveGroup
                                        enabled: uploadToPortal ? true : false
                                        onCheckedChanged: {
                                            if(checked){
                                                currentSharing = kPublicSharing;
                                            }
                                        }
                                        Accessible.role: Accessible.RadioButton
                                        Accessible.name: Singletons.Strings.everyonePublic
                                    }
                                }
                                Item {
                                    Layout.fillHeight: true
                                }
                            }
                        }
                }
            }

            Item {
                objectName: "finalSpacer"
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }

    // -------------------------------------------------------------------------

    FileDialog {
        id: folderChooser
        title: Singletons.Strings.saveTo
        //selectMultiple: false
        selectFolder: true
        //selectExisting: true
        modality: Qt.WindowModal
        //nameFilters: ["Tile Packages (*.tpk)"]
        onAccepted: {
            var folderPath = folderChooser.fileUrl.toString();
            var folderName = _extractFolderDirectory(folderPath);
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

    function _setDetailFormHeight(){
        var controls = detailsControls.children
        var initHeight = 0;
        for (var child in controls){
            if(controls[child].objectName !== "finalSpacer"){
                //console.log("--- %1 : %2 : %3".arg(controls[child].objectName).arg(controls[child].height).arg(controls[child].Layout.topMargin))
                initHeight += (controls[child].height + controls[child].Layout.topMargin + controls[child].Layout.bottomMargin);
                if(controls[child].height === 0){
                    //console.log("hidden: ",controls[child].objectName)
                    initHeight += controls[child].Layout.preferredHeight;
                }
            }
        }

        details.contentHeight = initHeight;
    }

    //--------------------------------------------------------------------------

    function _sanatizeTitle(inText){
        var title = inText.replace(/[^a-zA-Z0-9]/g,"_").toLocaleLowerCase();
        currentExportTitle = title;
        tpkFileTitleName.text = title + "_{uuid}.tpk";
    }

    //--------------------------------------------------------------------------

    function reset(){
        //desiredLevelsSlider.value = 0;
        desiredBufferInput.text = "";
        uploadToPortalRadioButton.checked = true;
        tpkSharingNotShared.checked = true;
        //saveToLocation.checked = false;
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
        if (!control.enabled) {
            return Singletons.Colors.formElementDisabledBackground;
        }
        else {
            return Singletons.Colors.formElementBackground;
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
