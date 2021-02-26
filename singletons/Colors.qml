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
import QtQuick 2.15

QtObject {

    id: colors

    readonly property color lightGray: "#f8f8f8"
    readonly property color mediumGray: "#e0e0e0"
    readonly property color darkGray: "#595959"
    readonly property color veryDarkGray: "#323232"

    readonly property color lightBlue: "#d2e9f9"
    readonly property color mainButtonBackgroundColor: "#196fa6"
    readonly property color mainButtonPressedColor: "#166090"

    readonly property color mainLabelFontColor: "#595959"
    readonly property color subtleBackground: "#efefef"

    readonly property color boldUIElementBackground: "#ddeedb"
    readonly property color boldUIElementFontColor: "#323232"

    readonly property color formElementBackground: "#fff"
    readonly property color formElementBorderColor: "#ddd"
    readonly property color formElementFontColor: "#323232"
    readonly property color formElementDisabledBackground: "#888"

    readonly property color specialBackground: "#ddeedb"

    readonly property string drawnExtentOutlineColor: "#de2900"
    readonly property string drawingExtentFillColor: "#10de2900"
}
