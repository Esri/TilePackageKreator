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

import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
//------------------------------------------------------------------------------
import "Portal"
import "AboutDialog"
import "AppMetrics"
import "singletons" as Singletons

//------------------------------------------------------------------------------

Item {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: appToolBar

    property StackView stackView
    property Portal portal
    property UpdatesDialog updates

    property string toolBarBackground: "#222"
    property string toolBarFontColor: "#fff"
    property double toolBarFontPointSize: sf(15)
    property string toolBarBorderColor: "#fff"
    property string toolBarButtonColor: "#fff"
    property string toolBarButtonBackgroundColor: "transparent"
    property string toolBarButtonHoverColor: "gold"
    property string toolBarButtonPressedColor: "orange"
    property string toolBarButtonDisabledColor: "#aaa"
    property int toolBarHeight: sf(50)
    property int toolBarWidth
    property int iconHeight: toolBarHeight - sf(25)
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
            spacing: sf(1)

            //------------------------------------------------------------------

            Button{
                id:backButton
                Layout.preferredWidth: toolBarHeight
                Layout.fillHeight: true

                ToolTip.visible: hovered
                ToolTip.text: Singletons.Strings.back

                background: Rectangle{
                    color: toolBarBackground
                    anchors.fill: parent
                }

                IconFont {
                    anchors.centerIn: parent
                    icon: _icons.chevron_left
                    iconSizeMultiplier: 1
                    color: _returnButtonColor(backButton)
                    Accessible.ignored: true
                }

                onClicked: {
                    stackView.pop();
                }

                Accessible.role: Accessible.Button
                Accessible.name: Singletons.Strings.goBackToPreviousView
                Accessible.description: Singletons.Strings.goBackToPreviousViewDesc
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
                    id: toolbarTitle
                    anchors.centerIn: parent
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: sf(20)
                    font.family: notoRegular
                    font.pointSize: toolBarFontPointSize
                    color: toolBarFontColor
                    textFormat: Text.RichText
                    text: ""
                    Accessible.role: Accessible.Heading
                    Accessible.name: text
                }
            }

            //------------------------------------------------------------------

            Button{
                id: updatesButton
                Layout.preferredWidth: toolBarHeight
                Layout.fillHeight: true
                ToolTip.visible: hovered
                ToolTip.text: Singletons.Strings.updatesAvailable
                enabled: false
                visible: false

                background: Rectangle{
                    color: toolBarBackground
                    anchors.fill: parent
                }

                IconFont {
                    anchors.centerIn: parent
                    icon: _icons.download_circle
                    iconSizeMultiplier: 1.1
                    color: _returnButtonColor(updatesButton)
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
                Accessible.name: Singletons.Strings.xUpdatesAvaliable.arg(numberOfUpdatesIndicatorCount.text)
                Accessible.description: Singletons.Strings.xUpdatesAvaliableDesc
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
                ToolTip.visible: hovered
                ToolTip.text: Singletons.Strings.feedback
                enabled: true

                background: Rectangle{
                    color: toolBarBackground
                    anchors.fill: parent
                }

                IconFont {
                    anchors.centerIn: parent
                    icon: _icons.chat_bubble
                    iconSizeMultiplier: 1.1
                    color: _returnButtonColor(feedbackButton)
                    Accessible.ignored: true
                }

                onClicked: {
                    feedbackDialog.open();
                }

                Accessible.role: Accessible.Button
                Accessible.name: Singletons.Strings.feedback
                Accessible.description: Singletons.Strings.feedbackDesc
                Accessible.onPressAction: {
                    if(enabled && visible){
                        clicked();
                    }
                }
            }

            //------------------------------------------------------------------

            Button {
                id: aboutButton
                Layout.preferredWidth: toolBarHeight
                Layout.fillHeight: true
                ToolTip.visible: hovered
                ToolTip.text: Singletons.Strings.aboutAndHelp

                background: Rectangle{
                    color: toolBarBackground
                    anchors.fill: parent
                }

                IconFont {
                    anchors.centerIn: parent
                    icon: _icons.info
                    iconSizeMultiplier: 1.1
                    color: _returnButtonColor(aboutButton)
                    Accessible.ignored: true
                }

                onClicked: {
                    aboutDialog.open()
                }

                Accessible.role: Accessible.Button
                Accessible.name: Singletons.Strings.aboutTheApp
                Accessible.description: Singletons.Strings.aboutTheAppDesc
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
                ToolTip.visible: hovered
                ToolTip.text: Singletons.Strings.history

                background: Rectangle{
                    color: toolBarBackground
                    anchors.fill: parent
                }

                IconFont {
                    anchors.centerIn: parent
                    icon: _icons.history
                    iconSizeMultiplier: 1.1
                    color: _returnButtonColor(historyButton)
                    Accessible.ignored: true
                }

                onClicked: {
                    stackView.push(hv);
                }

                Accessible.role: Accessible.Button
                Accessible.name: Singletons.Strings.exportAndUploadHistory
                Accessible.description: Singletons.Strings.exportAndUploadHistoryDesc
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
                ToolTip.visible: hovered
                ToolTip.text: (portal.user !== null && portal.user !== "" && portal.user !== undefined) ? Singletons.Strings.signOut + ": " + portal.user.fullName : "User Unknown"
                enabled: true

                background: Rectangle{
                    color: toolBarBackground
                    anchors.fill: parent
                }

                IconFont {
                    anchors.centerIn: parent
                    icon: _icons.sign_out
                    iconSizeMultiplier: 1.1
                    color: _returnButtonColor(userButton)
                    Accessible.ignored: true
                }

                onClicked: {
                    portal.signOut();
                    stackView.replace(null,startView);
                    //stackView.push({item: startView, replace: true});
                }

                Accessible.role: Accessible.Button
                Accessible.name: Singletons.Strings.signOut
                Accessible.description: Singletons.Strings.signOutDesc
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
