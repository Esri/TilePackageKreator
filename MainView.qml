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
import QtQuick.Layouts 1.1
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
//------------------------------------------------------------------------------
import "Portal"
import "HistoryManager"
import "AppMetrics"
import "DeepLinkingRequest"
//------------------------------------------------------------------------------

Item {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: mainView

    property Portal portal
    property Config config: Config{}
    property TilePackageDeepLinkRequest dlr: TilePackageDeepLinkRequest{}
    property App parentApp

    property AppMetrics appMetrics: AppMetrics{
        releaseType: "beta"
        parentApp: mainView.parentApp
        debug: true
        onAvailableUpdatesChanged: {
            if (availableUpdates.length > 0) {
                for (var i = 0; i < availableUpdates.length; i++) {
                    if (!availableUpdates[i].restricted_to_tags) {
                        uD.updates.append(availableUpdates[i]);
                    }
                }
                mainToolBar.updateCount = uD.updates.count;
            }
        }
    }

    property bool updatesAvailable: false
    property alias viewStack: mainStackView
    property alias appToolBar: mainToolBar

    // UI //////////////////////////////////////////////////////////////////////

    ColumnLayout {
        anchors.fill: parent
        spacing: 1

        AppToolBar {
            id: mainToolBar
            enabled: false
            stackView: mainStackView
            portal: mainView.portal
            updates: uD
            Layout.fillWidth: true
            Layout.preferredHeight: sf(50)
            toolBarBackground: app.info.properties.toolBarBackgroundColor
            toolBarBorderColor: app.info.properties.toolBarBorderColor
            toolBarFontColor: app.info.properties.toolBarFontColor
            toolBarFontPointSize: config.baseFontSizePoint
            toolBarButtonHoverColor: app.info.properties.mainButtonPressedColor
            toolBarButtonPressedColor: app.info.properties.mainButtonBackgroundColor
            backButtonEnabled: false
            backButtonVisible: false
            toolBarTitleLabel: "<strong style='font-size:large'>%1</strong> <span style='font-size:small;'>v%2.%3.%4</span>".arg(app.info.title).arg(app.info.value("version").major).arg(app.info.value("version").minor).arg(app.info.value("version").micro)
            onUpdatesButtonEnabledChanged: {
                console.log("MainView onUpdates: ", updatesButtonEnabled);
            }
        }

        StackView {
            id: mainStackView
            Layout.fillWidth: true
            Layout.fillHeight: true
            initialItem: startView
        }
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    Component{

        id: startView

        SignInView {

            portal: mainView.portal

            onLoginSuccess: {
                appMetrics.userName = portal.user.fullName;
                appMetrics.userEmail = portal.user.email;
                appMetrics.checkForUpdates();

                if (!calledFromAnotherApp) {
                    mainStackView.push(osv, {}, StackView.Immediate);
                }
                else {
                    getViewForAction();
                }
            }

            onLoginFailed: {}

        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: osv
        OperationSelectionView {
            config: mainView.config
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: utpkv
        UploadView {
            portal: mainView.portal
            config: mainView.config
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: asv
        AvailableServicesView {
            portal: mainView.portal
            config: mainView.config
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: etv
        ExportView {
            portal: mainView.portal
            config: mainView.config
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: btpkv
        BrowseOrgView {
            portal: mainView.portal
            config: mainView.config
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: hv
        HistoryView {
            config: mainView.config
        }
    }

    //--------------------------------------------------------------------------

    UpdatesDialog {
        id: uD
        metrics: appMetrics
    }

    //--------------------------------------------------------------------------

    Connections {
        target: app

        onIncomingUrlChanged: {
            parseIncomingUrl();
        }

    }

    // METHODS /////////////////////////////////////////////////////////////////

    function getViewForAction(){
        // TODO: Make the switch variable more agnostic maybe?
        switch (dlr.mainAction.toLowerCase()) {
            case "create":
                mainStackView.push(asv);
                break;
            case "upload":
                mainStackView.push(utpkv);
                break;
            default:
                mainStackView.push(osv);
                break;
         }
    }

    //--------------------------------------------------------------------------

    function parseIncomingUrl(){

        if (calledFromAnotherApp) {

            if (incomingUrl.toString() !== "") {

                if (dlr.parseUrl(incomingUrl)) {
                    try {
                        appMetrics.trackEvent("Called from another application: %1".arg(dlr.callingApplication));
                    }
                    catch(e) {
                    }
                    finally {

                        if (dlr.parameters !== null) {

                            dlr.parseParameters();

                            if (dlr.refreshToken !== null && dlr.handoffClientId !== null) {
                                portal.refreshToken = dlr.refreshToken;
                                portal.clientId = dlr.handoffClientId;
                                portal.renew();
                            }

                            /*if(dlr.token !== null && dlr.tokenExpiry !== null && dlr.username !== null && dlr.canPublish !== null){
                                portal.token = dlr.token;
                                portal.expires = new Date(dlr.tokenExpiry);
                                portal.user = dlr.username;
                                portal.username = dlr.username;
                                portal.info = dlr.canPublish;
                                getViewForAction();
                            }*/

                        }
                        else {
                            // do nothing as user will need to actually log in and then
                            // PortalSignInView will send them to getViewForAction()
                        }
                    }
                }
                else {
                    // the url parsed as bad so do nothing cause the user needs to sign in.
                }
            }
        }

    }

    //--------------------------------------------------------------------------

    function _uiEntryElementStates(control){
        if (!control.enabled) {
            return config.formElementDisabledBackground;
        }
        else {
            return config.formElementBackground;
        }
    }

    // END /////////////////////////////////////////////////////////////////////
}
