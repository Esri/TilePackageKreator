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

import QtQuick 2.15
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

import ArcGIS.AppFramework 1.0

TabView {
    id: tabView

    property color tabsTextColor: app.titleBarTextColor
    property color tabsBackgroundColor: app.titleBarBackgroundColor
    property color backgroundColor: app.backgroundColor
    property int tabsPadding: 4 * AppFramework.displayScaleFactor
    property real textSize: 13
    property int tabsAlignment: Qt.AlignHCenter
    property string fontFamily

    style: TabViewStyle {
        id: tabViewStyle

        tabsAlignment: tabView.tabsAlignment

        tab: Item {
            property int totalOverlap: tabOverlap * (control.count - 1)
            property real minTabWidth: height
            property real maxTabWidth: control.count > 0 ? (styleData.availableWidth + totalOverlap) / control.count : 0

            implicitWidth: Math.round(Math.max(minTabWidth, Math.min(maxTabWidth, tabText.implicitWidth + tabsPadding * 8)))
            //implicitHeight: Math.round(tabText.implicitHeight + tabsPadding * 4)
            height: Math.round(tabText.implicitHeight + tabsPadding * 4.5)

            Rectangle {
                anchors {
                    fill: parent
                    margins: tabsPadding
                }

                color: styleData.selected ? tabsTextColor : tabsBackgroundColor
                border {
                    color:  tabsTextColor
                    width: 1
                }
                radius: height / 2

                Text {
                    id: tabText

                    anchors {
                        fill: parent
                        leftMargin: tabsPadding
                        rightMargin: tabsPadding
                    }

                    text: styleData.title
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: styleData.selected ? tabsBackgroundColor : tabsTextColor
                    font {
                        bold: true//styleData.selected
                        pointSize: textSize
                        family: fontFamily
                    }
                }
            }
        }

        tabBar: Rectangle {
            color: tabsBackgroundColor

//            Rectangle {
//                anchors {
//                    left: parent.left
//                    right: parent.right
//                    bottom: parent.bottom
//                }

//                height: 1
//                color: "#30FFFFFF"
//            }
        }

        frame: Rectangle {
            color: backgroundColor
        }
    }
}
