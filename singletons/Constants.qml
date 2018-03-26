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

pragma Singleton
import QtQuick 2.7

QtObject {

    id: strings

    readonly property string kEnvelope: "envelope"
    readonly property string kMultipath: "multipath"
    readonly property string kPolygon: "polygon"
    readonly property string kRedraw: "redraw"
    readonly property string kDrawDraft: "draft"
    readonly property string kDrawFinal: "final"

    readonly property int kQtMapSpatialReference: 4326
    readonly property int kWebMercLatestWKID: 3857
    readonly property int kWebMercWKID: 102100
    readonly property string kWebMercSR: "WGS_1984_Web_Mercator_Auxiliary_Sphere"

    readonly property string kDatabasePath: "~/ArcGIS/Data/Sql"
    readonly property string kDatabaseName: "tilepackagekreator.sqlite"

    readonly property string kAllowAllZoomLevels: "allowAllZoomLevels"
    readonly property string kAllowNonWebMercatorServices: "allowNonWebMercatorServices"
    readonly property string kTimeOutUnresponsiveServices: "timeoutUnresponsiveServices"
    readonly property string kTimeOutValue: "timeoutValue"
}
