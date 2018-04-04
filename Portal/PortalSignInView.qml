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
import "../singletons" as Singletons


//------------------------------------------------------------------------------

Rectangle {
    id: signInView

    property alias bannerImage: image.source
    property alias bannerColor: banner.color
    property alias bannerTextColor: titleText.color
    property alias backgroundColor: signInView.color
    property bool dialogStyle: false

    property string portalName: portal ? portal.name : "<Portal Name>"
    property string title: busy ? qsTr("Signing in to %1").arg(portalName) : qsTr("Sign in to %1").arg(portalName)
    property string reason: portal.signInReason

    property Portal portal
    property Settings settings
    property string settingsGroup: "Portal"

    readonly property bool busy: portal ? portal.busy: false

    readonly property string messageCodePasswordExired: "LLS_0002"

    readonly property bool hasWebView: !(Qt.platform.os == "winrt") //|| Qt.platform.os == "winphone")
    readonly property bool useOAuth: hasWebView && portal.supportsOAuth

    property int buttonHeight: 35 * AppFramework.displayScaleFactor

    property string fontFamily: defaultFontFamily

    signal accepted()
    signal rejected()

    color: "white"

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        portalsList.read();
    }

    //--------------------------------------------------------------------------

    Connections {
        target: portal

        onCanPublishChanged: {
            if(!portal.clientMode) {
                if(portal.canPublish) {
                    accepted()
                }
            }
        }

        onSignedInChanged: {
            //console.log("PortalSignInView::onSignedInChange: ", portal.info, portal.user, portal.token);
            if (portal.signedIn && portal.user && (portal.user.orgId || portal.isPortal)) {
                if(portal.clientMode) {
                    accepted();
                }
            }
        }

        onError: {
            portal.busy = false;
            signInItem.visible = !useOAuth;
            if (portal.user && !(portal.user.orgId || portal.isPortal)) {
                errorText.text = qsTr("ArcGIS public account is not supported.") + "<br><br><br>" + qsTr("ArcGIS public account is a free personal account with limited usage and capabilities.") + "<br><br>" + qsTr("Please sign in using your ArcGIS organization account.");
            } else {
                errorText.text = error.message + "<br><br>" + (error.details || "")
            }
        }
    }

    //--------------------------------------------------------------------------

    PortalsList {
        id: portalsList

        settings: signInView.settings
        settingsGroup: signInView.settingsGroup
    }

    //--------------------------------------------------------------------------

    StackView {
        id: stackView

        anchors {
            fill: parent
        }

        initialItem: Rectangle {
            color: backgroundColor

            ColumnLayout {
                anchors.fill: parent

                spacing: 0

                Rectangle {
                    id: banner

                    Layout.fillWidth: true
                    Layout.preferredHeight: bannerColumn.height + 10 * AppFramework.displayScaleFactor * 2//+ buttonHeight

                    color: "#0079C1"

                    Column {
                        id: bannerColumn

                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            margins: 10 * AppFramework.displayScaleFactor
                        }

                        spacing: 5 * AppFramework.displayScaleFactor

                        RowLayout {
                            id: bannerRow

                            width: parent.width
                            spacing: 10 * AppFramework.displayScaleFactor

                            Item {
                                Layout.preferredWidth: buttonHeight
                                Layout.preferredHeight: buttonHeight
                                visible: false
                                enabled: false

                                ImageButton {
                                    id: rButton

                                    anchors.fill: parent

                                    source: dialogStyle ? "images/close.png" : "images/back.png"

                                    onClicked: {
                                        signInView.rejected();
                                    }

                                    Accessible.ignored: true
                                    Accessible.name: dialogStyle ? qsTr("Close") : qsTr("Back")
                                    Accessible.description: qsTr("This button will either close the dialog or go back to the previous view depending on the dialog style.")
                                    Accessible.onPressAction: {
                                        if(enabled && visible){
                                            clicked();
                                        }
                                    }
                                }

                                ColorOverlay {
                                    anchors.fill: rButton
                                    source: rButton.image
                                    color: bannerTextColor
                                    Accessible.ignored: true
                                }
                            }

                            Image {
                                id: image

                                Layout.fillHeight: true

                                fillMode: Image.PreserveAspectCrop
                                visible: source > ""
                                Accessible.ignored: true
                            }

                            Text {
                                id: titleText

                                Layout.fillWidth: true

                                text: title
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                font {
                                    pointSize: Singletons.Config.largeFontSizePoint
                                    bold: true
                                    family: fontFamily
                                }

                                Accessible.role: Accessible.StaticText
                                Accessible.name: title
                            }

                            Column {
                                Layout.preferredWidth: buttonHeight

                                spacing: 5 * AppFramework.displayScaleFactor

                                Image {
                                    width: parent.width
                                    height: width

                                    source: "images/security_unlock.png"
                                    visible: portal.ignoreSslErrors
                                    fillMode: Image.PreserveAspectFit
                                    Accessible.role: Accessible.Graphic
                                    Accessible.name: "Ignoring SSL Errors"
                                }

                                Item {
                                    width: parent.width
                                    height: width

                                    ImageButton {
                                        id: configButton

                                        anchors.fill: parent

                                        source: "images/gear.png"
                                        enabled: !busy

                                        onClicked: {
                                            stackView.push(signInOptions);
                                        }

                                        Accessible.role: Accessible.Button
                                        Accessible.name: qsTr("Configure Portals")
                                        Accessible.description: qsTr("This button will open the Portal configuration view.")
                                        Accessible.onPressAction: {
                                            if(enabled && visible){
                                                clicked();
                                            }
                                        }
                                    }

                                    ColorOverlay {
                                        anchors.fill: configButton
                                        source: configButton.image
                                        color: bannerTextColor
                                        Accessible.ignored: true
                                    }
                                }
                            }
                        }

                        Rectangle {
                            visible: reasonText.visible
                            width: parent.width
                            color: AppFramework.alphaColor(reasonText.color, 0.5)
                            height: 1
                            Accessible.ignored: true
                        }

                        Text {
                            id: reasonText

                            width: parent.width

                            visible: text > ""
                            text: reason
                            color: titleText.color
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                            font {
                                pointSize: 18
                                bold: true
                                family: fontFamily
                            }

                            Accessible.role: Accessible.AlertMessage
                            Accessible.name: reason
                        }
                    }
                }

                Text {
                    id: errorText

                    Layout.fillWidth: true
                    Layout.margins: 10 * AppFramework.displayScaleFactor

                    visible: text > ""
                    color: "red"
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    font {
                        pointSize: 16
                        bold: true
                        family: fontFamily
                    }

                    onLinkActivated: {
                        Qt.openUrlExternally(link);
                    }

                    Accessible.role: Accessible.AlertMessage
                    Accessible.name: errorText.text

                    Rectangle {
                        anchors.fill: parent
                        color: "white"
                        z: parent.z - 1
                        Accessible.ignored: true
                    }
                }

                Item {
                    id: signInItem

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Loader {
                        id: loader
                        anchors.fill: parent

                        sourceComponent: useOAuth ? oauthComponent : inputAreaComponent

                        onSourceComponentChanged: {
                            console.log("my source changed");
                        }

                        onActiveChanged: {
                            console.log("loader is active:", active);
                        }

                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    visible: !signInItem.visible
                    Accessible.ignored: true
                }
            }
        }

        onDepthChanged: {
            if (depth === 1) {
                loader.active = true;
            }
        }
    }

    //--------------------------------------------------------------------------

    Rectangle {
        anchors.fill: parent

        visible: busy
        color: "#60000000"

        ColorBusyIndicator {
            anchors.centerIn: parent

            backgroundColor: bannerColor
            running: busy
        }

        Accessible.role: Accessible.Animation
        Accessible.name: qsTr("Busy Indicator")
        Accessible.description: qsTr("This is an animation spinner that is visible when the view is busy.")
    }

    //--------------------------------------------------------------------------

    Component {
        id: inputAreaComponent

        BuiltInSignInView {
            id: inputArea

            anchors.fill: parent

            username: portal.username
            fontFamily: defaultFontFamily.family

            onRejected: {
                signInView.rejected();
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: oauthComponent

        OAuthSignInView {
            id: webViewContainer

            anchors.fill: parent

            //portal: signInView.portal
            visible: !busy
            authorizationUrl: signInView.portal.authorizationUrl
            hideCancel: !dialogStyle

            onAuthorizationUrlChanged: {
                console.log('authorization url changed: ', authorizationUrl)
                //loader.sourceComponent = undefined;
                //loader.sourceComponent = oauthComponent;
            }

            onAccepted: {
                //console.log('oauth accepted')
                portal.setAuthorizationCode(authorizationCode);
            }

            onRejected: {
                //console.log('outh rejected')
                signInView.rejected();
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: signInOptions

        PortalSettingsPage {

            fontFamily: signInView.fontFamily

            onPortalSelected: {

                //console.log("onPortalSelected:", JSON.stringify(portalInfo, undefined, 2));

                portal.signOut();

                portal.name = portalInfo.name;
                portal.ignoreSslErrors = portalInfo.ignoreSslErrors;
                portal.isPortal = portalInfo.isPortal;
                portal.supportsOAuth = portalInfo.supportsOAuth;
                portal.portalUrl = portalInfo.url;

                portal.writeSettings();
            }
        }
    }

    //--------------------------------------------------------------------------

    function forgotUrl(what) {
        var portalUrlInfo = AppFramework.urlInfo(portal.portalUrl);

        portalUrlInfo.scheme = "https";

        return portalUrlInfo.url + "/sharing/oauth2/troubleshoot?client_id=esriapps&redirect_uri=http://www.esri.com&response_type=token&forgotMy=" + what;
    }

    //--------------------------------------------------------------------------
}
