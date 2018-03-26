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
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
//------------------------------------------------------------------------------
import "Portal"
import "singletons" as Singletons
//------------------------------------------------------------------------------

App {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: app
    width: sf(900)
    height: sf(675)

    property bool calledFromAnotherApp: false
    property url incomingUrl

    property bool useIconFont: Qt.platform.os !== "windows" ? true : false

    property string icons: _icons.status == FontLoader.Ready ? _icons.name : "tilepackage"
    property string notoRegular: _notoRegular.status == FontLoader.Ready ? _notoRegular.name : "Noto Sans"
    property string notoBold: _notoBold.status == FontLoader.Ready ? _notoBold.name : "Noto Sans"
    property string notoItalic: _notoItalic.status == FontLoader.Ready ? _notoItalic.name : "Noto Sans"
    property string notoBoldItalic: _notoBoldItalic.status == FontLoader.Ready ? _notoBoldItalic.name : "Noto Sans"

    property bool allowAllLevels: app.settings.boolValue(Singletons.Constants.kAllowAllZoomLevels, false)
    property bool allowNonWebMercatorServices: app.settings.boolValue(Singletons.Constants.kAllowNonWebMercatorServices, false)
    property bool timeoutNonResponsiveServices: app.settings.boolValue(Singletons.Constants.kTimeOutUnresponsiveServices, true)
    property int timeoutValue: app.settings.numberValue(Singletons.Constants.kTimeOutValue, 7)

    Component.onCompleted: {
        if (!appDatabase.exists()) {
            appDatabase.createDatabase();
        }
    }

    // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////////

    onOpenUrl: {
        if(url.toString() !== ""){
            calledFromAnotherApp = true;
            incomingUrl = url;
        }
    }

    onAllowAllLevelsChanged: {
        app.settings.setValue(Singletons.Constants.kAllowAllZoomLevels, allowAllLevels);
    }

    onAllowNonWebMercatorServicesChanged: {
        app.settings.setValue(Singletons.Constants.kAllowNonWebMercatorServices, allowNonWebMercatorServices);
    }

    onTimeoutNonResponsiveServicesChanged: {
        app.settings.setValue(Singletons.Constants.kTimeOutUnresponsiveServices, timeoutNonResponsiveServices);
    }

    onTimeoutValueChanged: {
        app.settings.setValue(Singletons.Constants.kTimeOutValue, timeoutValue);
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    Portal {
        id: portal
        clientId: app.info.value("deployment").clientId
        clientMode: false
        settings: app.settings
    }

    //--------------------------------------------------------------------------

    MainView {
        anchors.fill: parent
        portal: portal
        parentApp: app
    }

    AppDb {
        id: appDatabase
    }

    //--------------------------------------------------------------------------

    FontLoader {
        id: _notoRegular
        source: "fonts/NotoSans-Regular.ttf"
    }
    FontLoader {
        id: _notoBold
        source: "fonts/NotoSans-Bold.ttf"
    }
    FontLoader {
        id: _notoItalic
        source: "fonts/NotoSans-Italic.ttf"
    }
    FontLoader {
        id: _notoBoldItalic
        source: "fonts/NotoSans-BoldItalic.ttf"
    }

    FontLoader {
        id: _icons
        source: "fonts/tilepackage.ttf"
        readonly property string app_studio: useIconFont ? "\ue904" : "images/appstudio.svg"
        property string add_bookmark: useIconFont ? "E" : "images/add-bookmark.svg"
        property string bookmark: useIconFont ? "C" : "images/bookmark.svg"
        property string chat_bubble: useIconFont ? "g" : "images/feedback.svg"
        property string checkmark: useIconFont ? "p" : "images/checkmark.svg"
        property string chevron_left: useIconFont ? "A" : "images/left-chevron.svg"
        property string chevron_right: useIconFont ? "B" : "images/right-chevron.svg"
        property string download: useIconFont ? "z" : "images/download.svg"
        property string download_circle: useIconFont ? "n" : "images/updates.svg"
        property string draw_extent: useIconFont ? "b" : "images/draw-extent.svg"
        property string draw_path: useIconFont ? "y" : "images/draw-path.svg"
        property string draw_polygon: useIconFont ? "D" : "images/draw-polygon.svg"
        property string draw_tool: useIconFont ? "F" : "images/draw-tool.svg"
        property string happy_face: useIconFont ? "x" : "images/happy.svg"
        property string history: useIconFont ? "f" : "images/history.svg"
        property string info: useIconFont ? "r" : "images/info.svg"
        property string loop: useIconFont ? "\uea2e" : "images/spinner.svg"
        property string magnifying_glass: useIconFont ? "l" : "images/search.svg"
        property string minus_sign: useIconFont ? "s" : "images/minus.svg"
        property string plus_sign: useIconFont ? "t" : "images/plus.svg"
        property string question: useIconFont ? "u" : "images/question.svg"
        property string redraw_last_path: useIconFont ? "d" : "images/redraw-last.svg"
        property string sad_face: useIconFont ? "w" : "images/sad.svg"
        property string settings: useIconFont ? "G" : "images/settings.svg"
        property string sign_out: useIconFont ? "c" : "images/sign-out.svg"
//        property string spinner: "\ue982"
        property string spinner2: useIconFont ? "i" : "images/spinner2.svg"
//        property string spinner3: "\ue983"
        property string trash_bin: useIconFont ? "m" : "images/trash.svg"
        property string upload: useIconFont ? "a" : "images/upload.svg"
        property string user: useIconFont ? "h" : "images/user.svg"
        property string warning: useIconFont ? "v" : "images/warning.svg"
        property string x_cross: useIconFont ? "q" : "images/close.svg"

        //--------------------------------------------------------------------------

        function getIconByName(name){
            return this[name];
        }
    }

    // -------------------------------------------------------------------------

    function sf(val){
        return val * AppFramework.displayScaleFactor;s
    }

    // END /////////////////////////////////////////////////////////////////////
}
