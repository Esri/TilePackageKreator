/* Copyright 2015 Esri
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

import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

import "../Controls"

//------------------------------------------------------------------------------

Rectangle {
    id: page

    signal portalSelected(var portalInfo)

    property int buttonHeight: 35 * AppFramework.displayScaleFactor

    property real minimumVersionMajor: 3
    property real minimumVersionMinor: 7
    readonly property real kMinimumVersion: combineVersionParts(minimumVersionMajor, minimumVersionMinor)
    readonly property string kPortalHelpUrl: "http://doc.arcgis.com/en/survey123/desktop/create-surveys/survey123withportal.htm"

    property bool showAuthentication: false

    property string fontFamily: notoRegular

    color: "white"

    Rectangle {
        id: portalsBanner

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        height: portalsBannerRow.height + 10 * AppFramework.displayScaleFactor * 2
        color: bannerColor

        RowLayout {
            id: portalsBannerRow

            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            ImageButton {
                Layout.preferredWidth: buttonHeight
                Layout.preferredHeight: buttonHeight

                source: "images/back.png"

                onClicked: {
                    stackView.pop()
                }
            }

            Text {
                Layout.fillWidth: true

                text: qsTr("Portals")
                font {
                    pointSize: titleText.font.pointSize
                    bold: titleText.font.bold
                    family: fontFamily
                }
                color: bannerTextColor
                horizontalAlignment: Text.AlignHCenter
            }

            Item {
                Layout.preferredWidth: buttonHeight
                Layout.preferredHeight: buttonHeight
            }
        }
    }

    ColumnLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: portalsBanner.bottom
            bottom: parent.bottom
            margins: 10 * AppFramework.displayScaleFactor
        }


        Text {
            Layout.fillWidth: true

            text: qsTr("Select your active ArcGIS Portal")
            font {
                pointSize: 14
                family: fontFamily
            }
            color: "#4c4c4c"
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            MouseArea {
                anchors.fill: parent

                onPressAndHold: {
                    showAuthentication = !showAuthentication;
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            color: bannerColor
        }

        ListView {
            id: portalsListView

            Layout.fillHeight: true
            Layout.fillWidth: true

            model: portalsList.model
            highlightFollowsCurrentItem: true
            highlight: portalHighlight
            currentIndex: portalsList.find(portal.portalUrl)
            spacing: 5 * AppFramework.displayScaleFactor
            clip: true

            onCurrentIndexChanged: {
                if (currentIndex >= 0) {
                    var portalInfo = portalsList.model.get(currentIndex);
                    portalSelected(portalInfo);
                }
            }


            delegate: Item {
                width: portalRow.width
                height: portalRow.height

                RowLayout {
                    id: portalRow

                    width: portalsListView.width

                    Image {
                        Layout.preferredWidth: 15 * AppFramework.displayScaleFactor * 2
                        Layout.preferredHeight: Layout.preferredWidth

                        source: isPortal ? "images/portal.png" : "images/online.png"
                        fillMode: Image.PreserveAspectFit
                    }

                    Image {
                        Layout.preferredWidth: 15 * AppFramework.displayScaleFactor * 2
                        Layout.preferredHeight: Layout.preferredWidth

                        source: supportsOAuth ? "images/oauth.png" : "images/builtin.png"
                        fillMode: Image.PreserveAspectFit
                        visible: source > "" && showAuthentication
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: portalText.height

                        Column {
                            id: portalText

                            width: parent.width


                            Text {
                                width: parent.width
                                text: name
                                font {
                                    pointSize: 14
                                    bold: index == portalsListView.currentIndex
                                    family: fontFamily
                                }
                                color: "black"
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            }

                            RowLayout {
                                width: parent.width
                                visible: index > 0

                                Image {
                                    Layout.preferredWidth: 15 * AppFramework.displayScaleFactor
                                    Layout.preferredHeight: Layout.preferredWidth

                                    source: ignoreSslErrors ? "images/security_unlock.png" : "" //"images/security_lock.png"
                                    fillMode: Image.PreserveAspectFit
                                    visible: source > ""
                                }

                                Text {
                                    Layout.fillWidth: true

                                    text: url
                                    font {
                                        pointSize: 12
                                        family: fontFamily
                                    }
                                    color: "#4c4c4c"
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                portalsListView.currentIndex = index;
                            }

                            onDoubleClicked: {
                                portalsListView.currentIndex = index;
                                stackView.pop();
                            }

                            onPressAndHold: {
                                Qt.openUrlExternally(url);
                            }
                        }
                    }

                    ImageButton {
                        width: 20 * AppFramework.displayScaleFactor
                        height: width

                        source: "images/trash_bin.png"
                        visible: index > 0 && index == portalsListView.currentIndex

                        onClicked: {
                            portalsList.remove(index);
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            visible: !addPortalGroupBox.visible

            color: bannerColor
        }

        StyledButton {
            Layout.alignment: Qt.AlignHCenter

            visible: !addPortalGroupBox.visible
            text: qsTr("Add Portal")
            fontFamily: page.fontFamily

            onClicked: {
                addPortalGroupBox.visible = true;
            }

        }

        GroupBox {
            id: addPortalGroupBox

            Layout.fillWidth: true

            visible: false

            ColumnLayout {
                anchors {
                    left: parent.left
                    right: parent.right
                }

                spacing: 5 * AppFramework.displayScaleFactor

                Text {
                    Layout.fillWidth: true

                    text: qsTr("URL of your Portal for ArcGIS")
                    font {
                        family: fontFamily
                    }

                    MouseArea {
                        anchors.fill: parent

                        onPressAndHold: {
                            forceBuiltIn.visible = !forceBuiltIn.visible;
                        }
                    }
                }

                TextField {
                    id: portalUrlField

                    Layout.fillWidth: true

                    enabled: !portalInfoRequest.isBusy
                    placeholderText: qsTr("Example: https://webadaptor.example.com/arcgis")
                    textColor: "black"
                }

                GridLayout {
                    id: credentialsLayout

                    Layout.fillWidth: true

                    columns: 2
                    rows: 2
                    visible: false

                    Text {
                        Layout.fillWidth: true

                        text: qsTr("Username")
                        font {
                            family: fontFamily
                        }
                    }

                    Text {
                        Layout.fillWidth: true

                        text: qsTr("Password")
                        font {
                            family: fontFamily
                        }
                    }

                    TextField {
                        id: userField

                        Layout.fillWidth: true

                        placeholderText: qsTr("Username")
                    }

                    TextField {
                        id: passwordField

                        Layout.fillWidth: true

                        placeholderText: qsTr("Password")
                        echoMode: TextInput.Password
                        inputMethodHints: Qt.ImhSensitiveData
                    }
                }

                StyledSwitchBox {
                    id: sslCheckBox

                    Layout.fillWidth: true

                    visible: false
                    checked: false
                    text: qsTr("Ignore SSL Errors")
                    fontFamily: page.fontFamily
                }

                StyledSwitchBox {
                    id: forceBuiltIn

                    Layout.fillWidth: true

                    visible: false
                    checked: false
                    text: "Force built In authentication"
                    fontFamily: page.fontFamily
                }

                Text {
                    id: addPortalError

                    Layout.preferredWidth: parent.width

                    visible: text > ""
                    color: "red"
                    font {
                        pointSize: 14
                        family: fontFamily
                    }
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }


                Text {
                    Layout.preferredWidth: parent.width

                    text: qsTr('<a href="%1">Learn more about managing portal connections</a>').arg(kPortalHelpUrl)
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font {
                        family: fontFamily
                    }

                    onLinkActivated: {
                        Qt.openUrlExternally(link);
                    }
                }

                RowLayout {
                    Layout.preferredWidth: parent.width

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    StyledButton {
                        text: qsTr("Add Portal")
                        enabled: portalUrlField.text.substring(0, 4).toLocaleLowerCase() === "http" && !portalInfoRequest.isBusy
                        fontFamily: page.fontFamily

                        onClicked: {
                            addPortalError.text = "";
                            portalInfoRequest.sendRequest(portalUrlField.text.trim());
                        }

                        NetworkRequest {
                            id: portalInfoRequest

                            property url portalUrl
                            property string text
                            property bool isBusy: readyState == NetworkRequest.ReadyStateProcessing || readyState == NetworkRequest.ReadyStateSending

                            method: "POST"
                            responseType: "json"
                            ignoreSslErrors: sslCheckBox.checked
                            user: userField.text
                            password: passwordField.text

                            onReadyStateChanged: {
                                if (readyState === NetworkRequest.ReadyStateComplete)
                                {
                                    if (status === 200) {

                                        console.log("self:", JSON.stringify(response, undefined, 2));

                                        if (response.isPortal && !response.supportsHostedServices) {
                                            addPortalError.text = qsTr("Tile Package Kreator requires that Portal for ArcGIS 10.3.1 or later and is configured with a Hosted Server and ArcGIS Data Store");
                                        } else {
                                            portalVersionRequest.send();
                                            infoRequest.send();
                                        }
                                    }
                                }
                            }

                            onErrorTextChanged: {
                                console.error("addPortal error:", errorCode, errorText);

                                switch (errorCode) {
                                case 6:
                                    sslCheckBox.visible = true;
                                    break;

                                case 204:
                                    credentialsLayout.visible = true;
                                    break;
                                }

                                if (errorCode) {
                                    addPortalError.text = "%1 (%2)".arg(errorText).arg(errorCode);
                                } else {
                                    addPortalError.text = "";
                                }
                            }

                            function sendRequest(u) {

                                portalUrl = u;
                                url = portalUrl + "/sharing/rest/portals/self";

                                var formData = {
                                    f: "pjson"
                                };

                                send(formData);
                            }

                            function addPortal(version) {
                                var name = response.name;
                                if (!(name > "")) {
                                    name = qsTr("%1 (%2)").arg(response.portalName).arg(portalUrl);
                                }

                                var supportsOAuth = response.supportsOAuth && !(forceBuiltIn.checked && forceBuiltIn.visible); // && !response.isPortal;

                                var portalInfo = {
                                    url: portalUrl.toString(),
                                    name: name,
                                    ignoreSslErrors: sslCheckBox.checked,
                                    isPortal: response.isPortal,
                                    supportsOAuth: supportsOAuth
                                };

                                var portalIndex = portalsList.append(portalInfo);

                                portalsListView.currentIndex = portalIndex;
                                portalUrlField.text = "";
                                userField.text = "";
                                passwordField.text = "";
                                sslCheckBox.checked = false;
                                addPortalGroupBox.visible = false;

                                console.log("portalInfo:", JSON.stringify(portalsList.model.get(portalIndex), undefined, 2));
                            }
                        }

                        NetworkRequest {
                            id: portalVersionRequest

                            url: portalInfoRequest.portalUrl + "/sharing/rest?f=json"
                            responseType: "json"
                            user: userField.text
                            password: passwordField.text

                            onReadyStateChanged: {
                                if (readyState === NetworkRequest.ReadyStateComplete)
                                {
                                    if (response.currentVersion) {
                                        var versionParts = response.currentVersion.split(".");
                                        var versionMajor = versionParts.length > 0 ? Number(versionParts[0]) : 0;
                                        var versionMinor = versionParts.length > 1 ? Number(versionParts[1]) : 0;
                                        var version = combineVersionParts(versionMajor, versionMinor);

                                        console.log("Portal version:", versionMajor, versionMinor, "response:", JSON.stringify(response, undefined, 2));

                                        if (version >= kMinimumVersion) {
                                            portalInfoRequest.addPortal(response.currentVersion);
                                        } else {
                                            addPortalError.text = qsTr("Tile Package Kreator requires Portal for ArcGIS 10.3.1 or later");
                                        }
                                    } else {
                                        console.error("Invalid version response:", JSON.stringify(response, undefined, 2));
                                    }
                                }
                            }

                            onErrorTextChanged: {
                                console.error("portalVersionRequest error", errorText);
                            }
                        }

                        NetworkRequest {
                            id: infoRequest

                            url: portalInfoRequest.portalUrl + "/sharing/rest/info?f=json"
                            responseType: "json"
                            user: userField.text
                            password: passwordField.text

                            onReadyStateChanged: {
                                if (readyState === NetworkRequest.ReadyStateComplete)
                                {
                                    console.log("info:", JSON.stringify(response, undefined, 2));
                                }
                            }

                            onErrorTextChanged: {
                                console.log("infoRequest error", errorText);
                                //addPortalError.text = errorText;
                            }
                        }
                    }

                    StyledButton {
                        text: qsTr("Cancel")
                        fontFamily: page.fontFamily

                        onClicked: {
                            addPortalGroupBox.visible = false;
                        }
                    }
                }
            }
        }

    }

    ColorBusyIndicator {
        anchors.centerIn: parent

        backgroundColor: signInView.bannerColor
        running: portalInfoRequest.isBusy
        visible: running
    }

    //--------------------------------------------------------------------------

    Component {
        id: portalHighlight

        Rectangle {
            width: ListView.view.currentItem.width
            height: ListView.view.currentItem.height
            color: "darkgrey"
            radius: 2
            y: ListView.view.currentItem.y
            Behavior on y {
                SpringAnimation {
                    spring: 3
                    damping: 0.2
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    function combineVersionParts(major, minor) {
        return major + minor / 1000;
    }

    //--------------------------------------------------------------------------
}

