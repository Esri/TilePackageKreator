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

import QtQuick 2.5

import ArcGIS.AppFramework 1.0

Item {
    id: fontManager

    property alias folder: fontsFolder
    property var families: []

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        loadFonts();
    }

    //--------------------------------------------------------------------------

    FileFolder {
        id: fontsFolder

        url: "../fonts"
    }

    //--------------------------------------------------------------------------

    function loadFonts() {
        console.log("Loading font files from:", fontsFolder.url);

        var fileNames = folder.fileNames("*.ttf");

        fileNames.forEach(loadFont);
    }

    //--------------------------------------------------------------------------

    function loadFont(fileName) {
        console.log("Loading font file:", fileName);

        var loader = fontLoader.createObject(fontManager,
                                             {
                                                 fileName: fileName
                                             });
    }

    //--------------------------------------------------------------------------

    function addFamily(family) {
        if (families.indexOf(family) < 0) {
            families.push(family);

            console.log("Loaded font family:", family);
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: fontLoader

        FontLoader {
            property string fileName

            source: fontsFolder.fileUrl(fileName)

            onStatusChanged: {
                if (status === FontLoader.Ready) {
                    addFamily(name);
                }
            }
        }
    }

    //--------------------------------------------------------------------------
}
