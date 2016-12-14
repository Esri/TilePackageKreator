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

import QtQuick 2.0
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
//------------------------------------------------------------------------------

QtObject {

    id: appConfig

    property string nextButton: qsTr("Next") +  " &#187;"

    property var availableServicesView: {
        "gridMargin": 8,
        "highlightColor": "#196fa6",
        "tileItemBackgroundColor": "#ffffff",
        "tileItemBorderColor": "#eeeeee"
    }

    property string appBrandColor: "#d94f27"

    //property string toolBarBackgroundColor: "#323232"
    //property string toolBarBorderColor: "#aaaaaa"
    //property string toolBarFontColor: "#ffffff"

    property string mainButtonBackgroundColor: "#196fa6"
    //property string mainButtonBorderColor: "#007ac2"
    property string mainButtonPressedColor: "#166090"
    //property string mainButtonFontColor: "#ffffff"
    //property int mainButtonBorderWidth: 1
    //property int mainButtonRadius: 0

    property string mainLabelFontColor: "#595959"
    property string subtleBackground: "#efefef"
    property string boldUIElementBackground: "#ddeedb"
    property string boldUIElementFontColor: "#323232"
    property string formElementBackground: "#fff"
    property string formElementBorderColor: "#ddd"
    property string formElementFontColor: "#323232"
    property string formElementDisabledBackground: "#888"
    property int formElementBorderWidth: 1
    property int formElementRadius: 0

    property int baseFontSizePoint: _setBaseFontSize()
    property double xSmallFontSizePoint: (baseFontSizePoint * 0.6 < 10 ) ? 10 : baseFontSizePoint * 0.6
    property double smallFontSizePoint: (baseFontSizePoint * 0.8 < 10 ) ? 10 : baseFontSizePoint * 0.8
    property double mediumFontSizePoint: baseFontSizePoint * 1.1
    property double largeFontSizePoint: baseFontSizePoint * 1.3

    property int qtMapSpatialReference: 4326
    property int webMercLatestWKID: 3857
    property int webMercWKID: 102100
    property string webMercSR: "WGS_1984_Web_Mercator_Auxiliary_Sphere"
    //property double mapDefaultLat: 39.8665
    //property double mapDefaultLong: -97.3105
    //property int mapDefaultZoomLevel: 3

    property var thumbnails: {
        "width":200,
        "height": 133
    }

    //--------------------------------------------------------------------------
    function _setBaseFontSize(){
        if(AppFramework.osName.toString() === "OS X"){
            return 16;
        }else{
            return 12;
        }
    }

    //--------------------------------------------------------------------------
    function buttonStates(control, style){
        var bStyle, color;

        bStyle = (style === undefined || style === null || style ==="") ? "normal" : style;

        switch(bStyle){
            case "normal":
                if(control.pressed){
                    color = mainButtonPressedColor;
                }
                else if(!control.enabled){
                   color = "#888";
                }
                else{
                    color = mainButtonBackgroundColor;
                }
                break;
            case "clear":
                if(control.pressed){
                    color = mainButtonPressedColor;
                }
                else{
                    color = "#fff"
                }
                break;
            case "major":
                if(control.pressed){
                    color = "#bddbee"
                }
                else{
                    color = "#fff"
                }
                break;

            default:
                break;
        }
        return color;
    }

}
