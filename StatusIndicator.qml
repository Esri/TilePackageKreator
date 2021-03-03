/* Copyright 2018 Esri
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

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
import "singletons" as Singletons
//------------------------------------------------------------------------------

Rectangle {

    id: esriStatusIndicator

    property bool hideAutomatically: false
    property bool showDismissButton: false
    property bool narrowLineHeight: false
    property int hideAfter: 30000
    property int containerHeight: 50
    property int statusTextFontSize: 14
    property int indicatorBorderWidth: 1
    property string statusTextFontColor: "#111"
    property alias message: statusText.text
    property alias statusTextObject: statusText

    readonly property var success: {
        "backgroundColor": "#DDEEDB",
        "borderColor": "#9BC19C"
    }

    readonly property var info: {
        "backgroundColor": "#D2E9F9",
        "borderColor": "#3B8FC4"
    }

    readonly property var warning: {
        "backgroundColor": "#F3EDC7",
        "borderColor": "#D9BF2B"
    }

    readonly property var error: {
        "backgroundColor": "#F3DED7",
        "borderColor": "#E4A793"
    }

    property var messageType: success

    signal show()
    signal hide()
    signal hideImmediately()
    signal linkClicked(string link)

    color: messageType.backgroundColor
    height: containerHeight
    Layout.preferredHeight: containerHeight
    border.width: indicatorBorderWidth
    border.color: messageType.borderColor
    visible: false

    //--------------------------------------------------------------------------

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Text {
            id: statusText
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: statusTextFontColor
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.RichText
            text: ""
            font.pointSize: statusTextFontSize
            font.family: defaultFontFamily
            wrapMode: Text.WordWrap
            lineHeight: narrowLineHeight ? .7 : 1
            onLinkActivated: {
                linkClicked(link.toString());
                Qt.openUrlExternally(link);
            }
        }

        Button {
            visible: showDismissButton
            enabled: showDismissButton
            Layout.fillHeight: true
            Layout.preferredWidth: parent.height

            background: Rectangle {
                anchors.fill: parent
                color: messageType.backgroundColor
                border.width: 1
                border.color: messageType.borderColor
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                anchors.margins: sf(8)

                IconFont {
                    anchors.centerIn: parent
                    iconFont.font.pointSize: Singletons.Config.mediumFontSizePoint
                    color: messageType.borderColor
                    icon: _icons.x_cross
                }
            }

            onClicked: {
                hide();
            }
        }
    }

    // SIGNALS /////////////////////////////////////////////////////////////////

    onShow: {
       esriStatusIndicator.opacity = 1;
       esriStatusIndicator.visible = true;
        if (hideAutomatically) {
            hideStatusMessage.start();
        }
    }

    //--------------------------------------------------------------------------

    onHide: {
        fader.start()
    }

    //--------------------------------------------------------------------------

    onHideImmediately: {
        esriStatusIndicator.visible = false;
        if (hideStatusMessage.running) {
            hideStatusMessage.stop();
        }
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    Timer {
        id: hideStatusMessage
        interval: hideAfter
        running: false
        repeat: false
        onTriggered: hide()
    }

    //--------------------------------------------------------------------------

    PropertyAnimation {
        id: fader
        from: 1
        to: 0
        duration: 1000
        property: "opacity"
        running: false
        easing.type: Easing.Linear
        target: esriStatusIndicator

        onStopped: {
            esriStatusIndicator.visible = false;
            if (hideStatusMessage.running) {
                hideStatusMessage.stop();
            }
        }
    }

    // END /////////////////////////////////////////////////////////////////////
}
