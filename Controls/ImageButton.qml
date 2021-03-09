/*******************************************************************************
 * Copyright 2021 Esri
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 ******************************************************************************/

import QtQuick 2.15
import QtGraphicalEffects 1.15

Rectangle {
    property alias source : buttonImage.source
    property alias image: buttonImage
    property alias glow : buttonGlow
    property bool checked : false
    property color checkedColor : "#00b2ff"
    property color pressedColor : "lightgrey"
    property color hoverColor : "grey"
    property color glowColor : "transparent"
    property bool enabled : true

    signal clicked
    signal doubleClicked
    signal pressAndHold

    color: "transparent"

    id: button
    width: 32
    height: 32

    Glow {
        id: buttonGlow
        visible: button.enabled && (mouseArea.pressed || mouseArea.hovering || checked || (glowColor != "transparent"))
        anchors.fill: parent
        radius: 12
        samples: 16
        spread: 0.75
        color: mouseArea.pressed
               ? pressedColor
               : (mouseArea.hovering
                  ? hoverColor
                  : (checked ? checkedColor : glowColor))
        source: buttonImage
    }

    Image {
        id: buttonImage
        anchors.fill: parent
        fillMode : Image.PreserveAspectFit
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouseArea

        property bool hovering: false

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: button.enabled && containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

        onEntered: {
            hovering = enabled;
        }

        onExited: {
            hovering = false;
        }

        onClicked: {
            if (button.enabled) {
                button.clicked();
            }
        }

        onDoubleClicked: {
            if (button.enabled) {
                button.doubleClicked();
            }
        }

        onPressAndHold: {
            if (button.enabled) {
                button.pressAndHold();
            }
        }
    }
}
