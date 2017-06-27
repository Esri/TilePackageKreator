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
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
import "../singletons" as Singletons
//------------------------------------------------------------------------------

Rectangle {
    id: progressIndicator

    readonly property string componentPath: app.folder.path + "/ProgressIndicator"

    property int containerHeight: sf(50)
    property string progressIndicatorBackground: "#fff"

    property int statusTextFontSize: 14
    property int statusTextMinimumFontSize: 9
    property int statusTextLeftMargin: sf(20)

    property string iconContainerBackground: progressIndicatorBackground
    property string successBackground: "green"
    property string workingBackground: "#007ac2"
    property string failedBackground: "red"
    property int iconContainerHeight: containerHeight
    property int iconContainerLeftMargin: 0
    property int iconHeight: iconContainerHeight - 20

    property alias progressIcon: statusIcon.text
    property alias progressText: statusText.text
    property alias statusText: statusText

    readonly property string success: icons.checkmark
    readonly property string failed: icons.x_cross
    readonly property string working: icons.spinner2

    signal show()
    signal hide()

    color: progressIndicatorBackground
    height: containerHeight
    Layout.preferredHeight: containerHeight

    //--------------------------------------------------------------------------

    Rectangle{
        id: statusIconContainer
        anchors.left: parent.left
        anchors.leftMargin: iconContainerLeftMargin
        anchors.verticalCenter: parent.verticalCenter
        width: iconContainerHeight
        height: iconContainerHeight
        radius: iconContainerHeight / 2
        color: iconContainerBackground

        Text{
            id:statusIcon
            anchors.centerIn: parent
            font.pointSize: Singletons.Config.largeFontSizePoint
            color: "#fff"
            font.family: iconFont
            text: ""
            fontSizeMode: Text.Fit
            minimumPointSize: Singletons.Config.smallFontSizePoint

            onTextChanged: {
                if(text === working){
                    rotator.start();
                }
                else{
                    rotator.stop();
                    statusIcon.rotation = 0;
                }
                if(iconContainerBackground !== "transparent") {
                    if( text === working ){
                        statusIconContainer.color = workingBackground;
                    }
                    if( text === success ){
                        statusIconContainer.color = successBackground;
                    }
                    if( text === failed ){
                        statusIconContainer.color = failedBackground;
                    }
                }
            }
        }
    }

    Text{
        id:statusText
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: statusIconContainer.right
        anchors.leftMargin: statusTextLeftMargin
        verticalAlignment: Text.AlignVCenter
        textFormat: Text.RichText
        fontSizeMode: Text.Fit
        minimumPointSize: statusTextMinimumFontSize
        text: ""
        font.pointSize: statusTextFontSize
        font.family: notoRegular
        onLinkActivated: {
            Qt.openUrlExternally(link);
        }
    }

    // SIGNALS /////////////////////////////////////////////////////////////////

    onShow: {
        progressIndicator.visible = true;
    }

    onHide: {
        progressIndicator.visible = false;
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    RotationAnimation{
        id:rotator
        direction: RotationAnimation.Clockwise
        from: 0
        to: 360
        duration: 2000
        property: "rotation"
        target: statusIcon
        loops: Animation.Infinite
    }

    // END /////////////////////////////////////////////////////////////////////
}
