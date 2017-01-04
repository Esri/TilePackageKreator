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
import QtGraphicalEffects 1.0
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
//------------------------------------------------------------------------------
import "Portal"
import "AboutDialog"
import "AppMetrics"
//------------------------------------------------------------------------------

Item {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: appToolBar

    property StackView stackView
    property Portal portal
    property UpdatesDialog updates

    property string toolBarBackground: "#222"
    property string toolBarFontColor: "#fff"
    property double toolBarFontPointSize: 15 * AppFramework.displayScaleFactor
    property string toolBarBorderColor: "#fff"
    property string toolBarButtonColor: "#fff"
    property string toolBarButtonBackgroundColor: "transparent"
    property string toolBarButtonHoverColor: "gold"
    property string toolBarButtonPressedColor: "orange"
    property string toolBarButtonDisabledColor: "#aaa"
    property int toolBarHeight: 50 * AppFramework.displayScaleFactor
    property int toolBarWidth
    property int iconHeight: toolBarHeight - (25 * AppFramework.displayScaleFactor)
    property int updateCount: 0

    // -------------------------------------------------------------------------

    property alias toolBarTitleLabel: toolbarTitle.text
    property alias backButtonVisible: backButton.visible
    property alias backButtonEnabled: backButton.enabled
    property alias updatesButtonVisible: updatesButton.visible
    property alias updatesButtonEnabled: updatesButton.enabled
    property alias updateIndicatorVisible: numberOfUpdatesIndicator.visible
    property alias updateIndicatorCount: numberOfUpdatesIndicatorCount.text
    property alias feedbackButtonVisible: feedbackButton.visible
    property alias feedbackButtonEnabled: feedbackButton.enabled
    property alias historyButtonVisible: historyButton.visible
    property alias historyButtonEnabled: historyButton.enabled
    property alias aboutButtonVisible: aboutButton.visible
    property alias aboutButtonEnabled: aboutButton.enabled
    property alias userButtonVisible: userButton.visible
    property alias userButtonEnabled: userButton.enabled

    // UI //////////////////////////////////////////////////////////////////////

    Rectangle{
        anchors.fill: parent
        color: toolBarBorderColor
        Accessible.role: Accessible.Pane

        RowLayout {
            anchors.fill: parent
            spacing: 1 * AppFramework.displayScaleFactor

            //------------------------------------------------------------------

            Button{
                id:backButton
                Layout.preferredWidth: toolBarHeight
                Layout.fillHeight: true
                tooltip: qsTr("Back")

                style: ButtonStyle{
                    background: Rectangle{
                        color: toolBarBackground
                        anchors.fill: parent
                    }
                }

                Text{
                    anchors.centerIn: parent
                    font.pointSize: config.largeFontSizePoint
                    color: _returnButtonColor(backButton)
                    font.family: icons.name
                    text: icons.chevron_left
                    Accessible.ignored: true
                }

                onClicked: {
                    stackView.pop();
                }

                Accessible.role: Accessible.Button
                Accessible.name: qsTr("Go Back to previous view")
                Accessible.description: qsTr("This button will take you back to the previous view. The action on this button will only work when the button is enabled via the application.")
                Accessible.onPressAction: {
                    if(enabled && visible){
                        clicked();
                    }
                }
            }

            //------------------------------------------------------------------

            Rectangle {
                color: toolBarBackground
                Layout.fillWidth: true
                Layout.fillHeight: true
                Accessible.role: Accessible.Pane

                Text {
                    id:toolbarTitle
                    anchors.centerIn: parent
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 20 * AppFramework.displayScaleFactor
                    font.pointSize: toolBarFontPointSize
                    color: toolBarFontColor
                    textFormat: Text.RichText
                    text: ""
                    font.family: notoRegular.name
                    Accessible.role: Accessible.Header
                    Accessible.name: text
                }
            }

            //------------------------------------------------------------------

            Button{
                id: updatesButton
                Layout.preferredWidth: toolBarHeight
                Layout.fillHeight: true
                tooltip: qsTr("Updates Available")
                enabled: false
                visible: false

                style: ButtonStyle{
                    background: Rectangle{
                        color: toolBarBackground
                        anchors.fill: parent
                    }
                }

                Text{
                    anchors.centerIn: parent
                    font.pointSize: config.largeFontSizePoint * 1.1
                    color: _returnButtonColor(updatesButton)
                    font.family: icons.name
                    text: icons.download_circle
                    Accessible.ignored: true
                }

                Rectangle{
                    id: numberOfUpdatesIndicator
                    visible: false
                    color: "orange"
                    width: parent.width/2.4
                    height: parent.width/2.4
                    radius: (parent.width/2.4) / 2
                    anchors.top: updatesButton.top
                    anchors.right: updatesButton.right
                    anchors.topMargin: 4 * AppFramework.displayScaleFactor
                    anchors.rightMargin: 4 * AppFramework.displayScaleFactor
                    Text{
                        id: numberOfUpdatesIndicatorCount
                        anchors.centerIn: parent
                        text: "0"
                        color:"white"
                    }
                    Accessible.ignored: true
                }

                onClicked: {
                    updates.open();
                }

                Accessible.role: Accessible.Button
                Accessible.name: qsTr("%1 Updates are available".arg(numberOfUpdatesIndicatorCount.text))
                Accessible.description: qsTr("This button is enabled when there are updates available to the application. The current number of updates available is %1. The action on this button will only work when the button is enabled via the application.".arg(numberOfUpdatesIndicatorCount.text))
                Accessible.onPressAction: {
                    if(enabled && visible){
                        clicked();
                    }
                }
            }

            //------------------------------------------------------------------

            Button{
                id: feedbackButton
                Layout.preferredWidth: toolBarHeight
                Layout.fillHeight: true
                tooltip: qsTr("Feedback")
                enabled: true

                style: ButtonStyle{
                    background: Rectangle{
                        color: toolBarBackground
                        anchors.fill: parent
                    }
                }

                Text{
                    anchors.centerIn: parent
                    font.pointSize: config.largeFontSizePoint * 1.1
                    color: _returnButtonColor(feedbackButton)
                    font.family: icons.name
                    text: icons.chat_bubble
                }

                onClicked: {
                    feedbackDialog.open();
                }

                Accessible.role: Accessible.Button
                Accessible.name: qsTr("Feedback")
                Accessible.description: qsTr("This button opens up a dialog that allows a user to submit feedback on the application. The action on this button will only work when the button is enabled via the application.")
                Accessible.onPressAction: {
                    if(enabled && visible){
                        clicked();
                    }
                }
            }

            //------------------------------------------------------------------

            Button{
                id: aboutButton
                Layout.preferredWidth: toolBarHeight
                Layout.fillHeight: true
                tooltip: qsTr("About and Help")

                style: ButtonStyle{
                    background: Rectangle{
                        color: toolBarBackground
                        anchors.fill: parent
                    }
                }

                Text{
                    anchors.centerIn: parent
                    font.pointSize: config.largeFontSizePoint * 1.1
                    color: _returnButtonColor(aboutButton)
                    font.family: icons.name
                    text: icons.info
                }

                onClicked: {
                    aboutDialog.open()
                }

                Accessible.role: Accessible.Button
                Accessible.name: qsTr("About the app")
                Accessible.description: qsTr("This button opens up a dialog that provides information about this application. The action on this button will only work when the button is enabled via the application.")
                Accessible.onPressAction: {
                    if(enabled && visible){
                        clicked();
                    }
                }
            }

            //------------------------------------------------------------------

            Button{
                id: historyButton
                Layout.preferredWidth: toolBarHeight
                Layout.fillHeight: true
                tooltip: qsTr("History")

                style: ButtonStyle{
                    background: Rectangle{
                        color: toolBarBackground
                        anchors.fill: parent
                    }
                }

                Text{
                    anchors.centerIn: parent
                    font.pointSize: config.largeFontSizePoint * 1.1
                    color: _returnButtonColor(historyButton)
                    font.family: icons.name
                    text: icons.history
                }

                onClicked: {
                    stackView.push({item: hv});
                }

                Accessible.role: Accessible.Button
                Accessible.name: qsTr("Export and Upload History")
                Accessible.description: qsTr("This button will open the export and upload history view. The action on this button will only work when the button is enabled via the application.")
                Accessible.onPressAction: {
                    if(enabled && visible){
                        clicked();
                    }
                }
            }

            //------------------------------------------------------------------

            Button{
                id: userButton
                Layout.preferredWidth: toolBarHeight
                Layout.fillHeight: true
                tooltip: (portal.user !== null && portal.user !== "" && portal.user !== undefined) ? qsTr("Sign out") + ": " + portal.user.fullName : "User Unknown"
                enabled: true

                style: ButtonStyle{
                    background: Rectangle{
                        color: toolBarBackground
                        anchors.fill: parent
                    }
                }

                Text{
                    anchors.centerIn: parent
                    font.pointSize: config.largeFontSizePoint * 1.1
                    color: _returnButtonColor(userButton)
                    font.family: icons.name
                    text: icons.sign_out
                }

                onClicked: {
                    portal.signOut();
                    stackView.push({item: startView, replace: true});
                }

                Accessible.role: Accessible.Button
                Accessible.name: qsTr("Sign out")
                Accessible.description: qsTr("This button will sign the user out of the application and return to the sign in screen. The action on this button will only work when the button is enabled via the application.")
                Accessible.onPressAction: {
                    if(enabled && visible){
                        clicked();
                    }
                }
            }

            //------------------------------------------------------------------

        }
    }

    // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////////

    onUpdateCountChanged: {
        if(updateCount > 0){
            updatesButtonEnabled = true;
            updatesButtonVisible = true;
            updateIndicatorVisible = true;
            updateIndicatorCount = updateCount.toString();
        }
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    AboutDialog{
        id: aboutDialog
    }

    //--------------------------------------------------------------------------

    FeedbackDialog{
        id: feedbackDialog
        metrics: mainView.appMetrics
    }

    // METHODS /////////////////////////////////////////////////////////////////

    function _returnButtonColor(cntrl){
        if(cntrl.enabled === false){
            return toolBarButtonDisabledColor;
        }
        else if(cntrl.hovered){
            return toolBarButtonHoverColor;
        }
        else if(cntrl.pressed){
            return toolBarButtonPressedColor;
        }
        else{
            return toolBarButtonColor;
        }
    }

    // END /////////////////////////////////////////////////////////////////////

}
