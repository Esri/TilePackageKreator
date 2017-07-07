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
//------------------------------------------------------------------------------

App {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: app
    width: sf(900)
    height: sf(675)

    property bool calledFromAnotherApp: false
    property url incomingUrl

    property string icons: _icons.status == FontLoader.Ready ? _icons.name : "tilepackage"
    property string notoRegular: _notoRegular.status == FontLoader.Ready ? _notoRegular.name : "Noto Sans"
    property string notoBold: _notoBold.status == FontLoader.Ready ? _notoBold.name : "Noto Sans"
    property string notoItalic: _notoItalic.status == FontLoader.Ready ? _notoItalic.name : "Noto Sans"
    property string notoBoldItalic: _notoBoldItalic.status == FontLoader.Ready ? _notoBoldItalic.name : "Noto Sans"

    Component.onCompleted: {
        if (!appDatabase.exists()) {
            appDatabase.createDatabase();
        }

         appDatabase.read("SELECT * FROM 'exports'");
    }

    // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////////

    onOpenUrl: {
        if(url.toString() !== ""){
            calledFromAnotherApp = true;
            incomingUrl = url;
        }
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
        property string bookmark: "C"
        property string chat_bubble: "g"
        property string checkmark: "p"
        property string chevron_left: "A"
        property string chevron_right: "B"
        property string download: "z"
        property string download_circle: "n"
        property string draw_extent: "b"
        property string draw_path: "y"
        property string happy_face: "x"
        property string history: "f"
        property string info: "r"
        property string loop: "\uea2e"
        property string magnifying_glass: "l"
        property string minus_sign: "s"
        property string plus_sign: "t"
        property string question: "u"
        property string redraw_last_path: "d"
        property string sad_face: "w"
        property string sign_out: "c"
//        property string spinner: "\ue982"
        property string spinner2: "i"
//        property string spinner3: "\ue983"
        property string trash_bin: "m"
        property string upload: "a"
        property string user: "h"
        property string warning: "v"
        property string x_cross: "q"

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
