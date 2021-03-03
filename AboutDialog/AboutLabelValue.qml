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

import QtQuick 2.15
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0

Item {
    id: labelValue

    property alias label: labelText.text
    property alias value: valueText.text
    property alias font: valueText.font
    property alias color: labelText.color
    property alias valueColor: valueText.color

    property int valueType: 0

    signal clicked

    Layout.fillWidth: true

    visible: value > ""
    height: labelText.height

    Text {
        id: labelText
        font {
            pointSize: valueText.font.pointSize
            bold: !valueText.font.bold
        }
        font.family: defaultFontFamily
        text: "Label"
        anchors {
            left: parent.left
            top: parent.top
        }
    }

    Text {
        id: valueText
        font {
            pointSize: 9
            bold: true
        }
        font.family: defaultFontFamily
        color: labelText.color

        wrapMode: Text.WordWrap
        elide: Text.ElideRight
        maximumLineCount: 1
        text: ""
        anchors {
            left: labelText.right
            leftMargin: 5
            top: labelText.top
            right: parent.right
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: valueType === 1 ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: {
            switch (valueType) {
            case 1:
                Qt.openUrlExternally(AppFramework.fileInfo(parent.value).url);
                break;

            default:
                labelValue.clicked();
                break;
            }
        }
    }
}
