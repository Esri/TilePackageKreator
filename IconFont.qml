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
import QtGraphicalEffects 1.0
import "singletons" as Singletons

Item {
    id: _tpkIcon

    objectName: "appStudioIcon"

    property bool useIconFont: app.useIconFont
    property color color
    property double iconSizeMultiplier: 1.0
    property int iconImageSize: 22
    property string icon

    property alias iconImage: _iconImage
    property alias iconFont: _iconFont

    Text {
        id: _iconFont
        visible: useIconFont
        text: useIconFont ? _tpkIcon.icon : ""
        color: _tpkIcon.color
        anchors.centerIn: parent

        font {
            pointSize: Singletons.Config.largeFontSizePoint * iconSizeMultiplier
            family: icons
        }
    }

    Image {
        id: _iconImage
        visible: !useIconFont
        anchors.centerIn: _tpkIcon
        source: !useIconFont ? _tpkIcon.icon : "images/alpha.svg"
        sourceSize.width: _tpkIcon.iconImageSize * _tpkIcon.iconSizeMultiplier
        sourceSize.height: _tpkIcon.iconImageSize * _tpkIcon.iconSizeMultiplier
        mipmap: true
    }

    ColorOverlay {
        id: colorOverlay
        visible: !useIconFont
        anchors.fill: _iconImage
        source: _iconImage
        color: _tpkIcon.color
    }

    Accessible.role: Accessible.Graphic

    // END /////////////////////////////////////////////////////////////////////
}
