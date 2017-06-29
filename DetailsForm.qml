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
import "singletons" as Singletons
import "Controls" as Controls
//------------------------------------------------------------------------------

Rectangle {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: tpkDetailsForm

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
    property bool exportOnly: false
    property bool uploadOnly: false
    property bool exportPathBuffering: false
    property bool uploadToPortal: true
    property bool usesMetric: localeIsMetric()

    readonly property string kOrgSharing: "org"
    readonly property string kPublicSharing: "everyone"

    property alias tpkZoomLevels: desiredLevelsSlider.second
    property alias tpkBottomZoomLevel: desiredLevelsSlider.first
    property alias tpkTopZoomLevel: desiredLevelsSlider.second
    property alias tpkTitle: tpkTitleTextField.text
    //property alias tpkSharing: tpkDetailsForm.currentSharing
    property alias tpkDescription: tpkDescriptionTextArea.text
    property alias exportToFolder: folderChooser.folder

    signal exportZoomLevelsChanged()
    signal exportBufferDistanceChanged()

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

            onVisibleChanged: {
                if (bufferRadiusContainer.visible) {
                    details.contentHeight += bufferRadiusContainer.controlHeight;
                }
                else {
                    details.contentHeight -= bufferRadiusContainer.controlHeight;
                }
            }
        }

        ColumnLayout{
            anchors.fill: parent
            anchors.margins: sf(10)
            spacing: 0

            Component.onCompleted: {
               details.contentHeight = childrenRect.height;
            }

            //----------------------------------------------------------------------

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: sf(70)
                visible: exportAndUpload
                enabled: exportAndUpload

                ColumnLayout{
                    anchors.fill: parent
                    spacing:0

                    Text {
                        text: Singletons.Strings.numberOfZoomLevels
                        color: Singletons.Colors.darkGray
                        font.pointSize: Singletons.Config.smallFontSizePoint
                        font.family: notoRegular
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
                                onValueChanged: {
                                   tpkDetailsForm.exportZoomLevelsChanged();
                                }
                            }

                            Connections {
                                target: desiredLevelsSlider.first
                                onValueChanged: {
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
                                font.family: notoRegular
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
                        font.family: notoRegular
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
                        font.family: notoRegular
                        color: Singletons.Colors.darkGray
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
                Layout.fillWidth: true
                Layout.preferredHeight: sf(10)
                visible: false
                Accessible.ignored: true
                Text {
                    id: tpkFileTitleName
                    anchors.fill: parent
                    font.pointSize: Singletons.Config.xSmallFontSizePoint
                    font.family: notoRegular
                    color: Singletons.Config.formElementFontColor
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

            //----------------------------------------------------------------------

            Text {
                text: Singletons.Strings.saveTo //qsTr("Save To")
                color: Singletons.Colors.darkGray
                font.pointSize: Singletons.Config.smallFontSizePoint
                font.family: notoRegular
                Layout.fillWidth: true
                Layout.preferredHeight: sf(20)
                Accessible.role: Accessible.Heading
                Accessible.name: text
                visible: exportOnly
            }

            Item {
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
                                font.family: notoRegular
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
                            font.family: notoRegular
                            fontSizeMode: Text.Fit
                            minimumPointSize: 10
                            verticalAlignment: Text.AlignVCenter
                            color: Singletons.Config.formElementFontColor

                            Accessible.role: Accessible.StaticText
                            Accessible.name: Singletons.Strings.saveToLocationDesc
                        }
                    }
                }
            }

            //----------------------------------------------------------------------

            Rectangle {
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
                id: uploadToPortalDetailsContainer
                Layout.fillHeight: true
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
                                   font.family: notoRegular
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
                                   font.family: notoRegular
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
                            Layout.preferredHeight: sf(60)
                            Layout.bottomMargin: sf(10)

                            TextArea {
                                id: tpkDescriptionTextArea
                                enabled: false
                                anchors.fill: parent
                                property int maximumLength: 4000
                                readOnly: uploadToPortal ? false : true
                                selectByMouse: true
                                wrapMode: Text.Wrap
                                placeholderText: Singletons.Strings.descriptionCopyPaste

                                color: Singletons.Config.formElementFontColor
                                font.family: notoRegular
                                font.pointSize: Singletons.Config.xSmallFontSizePoint
                                background: Rectangle {
                                    color: _uiEntryElementStates(parent)
                                    border.width: Singletons.Config.formElementBorderWidth
                                    border.color: Singletons.Config.formElementBorderColor
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

                        //------------------------------------------------------

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: sf(30)
                            Label {
                                text: Singletons.Strings.shareThisItemWith
                                font.pointSize: Singletons.Config.smallFontSizePoint
                                font.family: notoRegular
                                color: Singletons.Config.mainLabelFontColor
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
            return Singletons.Config.formElementDisabledBackground;
        }
        else {
            return Singletons.Config.formElementBackground;
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
