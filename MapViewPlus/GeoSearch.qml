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

import QtQuick 2.7
import QtQuick.Controls 1.4 as OldControls
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtPositioning 5.3
import QtLocation 5.3
import QtQml 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
//------------------------------------------------------------------------------
import "../singletons" as Singletons
import "../Controls" as Controls
import "../"
//------------------------------------------------------------------------------

Rectangle {

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: geoSearchMenu

    anchors.fill: parent
    color: "white"
    //radius: sf(5)

    property alias geocodeModel: geocodeModel
    readonly property bool busy: geocodeModel.status === GeocodeModel.Loading
    property alias textChangedTimeout: geocodeTimer.interval
    property alias bounds: geocodeModel.bounds
    property alias limit: geocodeModel.limit

    property Component locationDelegate: locationDelegate
    property int minimumLocationDelegateHeight: 40 * AppFramework.displayScaleFactor
    property int viewLimit: 4
    property var referenceCoordinate: QtPositioning.coordinate()
    property var locale: Qt.locale()

    //--------------------------------------------------------------------------

    signal locationClicked(Location location)
    signal locationDoubleClicked(Location location)
    signal locationPressAndHold(Location location)
    signal inputCoordinate(var coordinate)
    signal popupListClosed()

    //--------------------------------------------------------------------------

    onBusyChanged: {
        if (busy){
            rotator.start();
        }
        else {
            rotator.stop();
            searchAndStatus.rotation = 0;
        }
    }

    // UI //////////////////////////////////////////////////////////////////////

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            id: searchIcon
            Layout.fillHeight: true
            Layout.preferredWidth: height + sf(6)
            Canvas {
                anchors.fill: parent
                onPaint: {
                    if (available) {
                        var _width = height;
                        var ctx = getContext("2d");
                        ctx.fillStyle = Singletons.Colors.lightBlue;
                        ctx.beginPath();
                        ctx.moveTo(0, 0);
                        ctx.lineTo(_width,0);
                        ctx.lineTo(_width + sf(6), height / 2);
                        ctx.lineTo(_width,height);
                        ctx.lineTo(0,height);
                        ctx.closePath();
                        ctx.fill();
                    }
                }
            }

            Item {
                id: searchButton
                width: height
                height: parent.height
                anchors.left: parent.left

                IconFont {
                    id: searchAndStatus
                    anchors.centerIn: parent
                    icon: busy ? _icons.spinner2 : _icons.magnifying_glass
                    iconSizeMultiplier: 1
                    color: !busy ? Singletons.Colors.mainButtonBackgroundColor : "green"
                }

                RotationAnimation {
                    id: rotator
                    direction: RotationAnimation.Clockwise
                    from: 0
                    to: 360
                    duration: 2000
                    property: "rotation"
                    target: searchAndStatus
                    loops: Animation.Infinite
                }
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Controls.StyledTextField {
                id: textField
                anchors.fill: parent
                anchors.margins: sf(5)
                rightPadding: clearButton.width + sf(2)

                onTextChanged: {
                    if (text <= "") {
                        geoSearchMenu.clear();
                    }
                    else {
                        geocodeTimer.restart();
                    }
                }

                onEditingFinished: {
                    if (text.substr(0, 1) === '@') {
                        parseCoordinate(text.substr(1).trim());
                    }
                }

                onFocusChanged: {
                    if (focus && geocodeModel.count > 0) {
                        locationPopup.open();
                    }
                }
            }

            Item {
                id: placeholderText
                width: textField.width - clearButton.width
                height: textField.height
                anchors.left: textField.left
                anchors.leftMargin: textField.leftPadding
                anchors.top: textField.top
                visible: textField.text === ""

                Text {
                    anchors.fill: parent
                    color: "#aaa"
                    verticalAlignment: Text.AlignVCenter
                    text: Singletons.Strings.searchAddressOrLatLon
                }
            }

            Item {
                id: clearButton
                height: textField.height
                width: textField.height - sf(7)
                anchors.top: textField.top
                anchors.right: textField.right
                visible: textField.text > ""

                Button {
                    id: clearText
                    anchors.fill: parent
                    enabled: textField.text > ""
                    background: Item {
                    }
                    contentItem: Rectangle {
                        anchors.centerIn: clearText
                        width: parent.width - sf(5)
                        height: width
                        radius: width / 2
                        color: clearText.enabled ? app.info.properties.mainButtonBorderColor : Singletons.Colors.lightGray

                        IconFont {
                            anchors.fill: parent
                            iconFont.verticalAlignment: Text.AlignVCenter
                            iconFont.horizontalAlignment: Text.AlignHCenter
                            iconFont.font.pointSize: 9
                            color: "#fff"
                            icon: _icons.x_cross
                        }
                    }
                    onClicked: {
                        textField.clear();
                    }
                }
            }
        }
    }

    Popup {
        id: locationPopup
        width: textField.width //parent.width
        height: sf(200)
        x: searchIcon.width + sf(5)
        y: textField.height + sf(5)

        background: Rectangle {
            color: "#fff"
            border.color: Singletons.Colors.mediumGray
            border.width: sf(1)
        }

        ListView {
            anchors.fill: parent
            id: resultsView

            model: geocodeModel
            spacing: 2 * AppFramework.displayScaleFactor
            delegate: locationDelegate
            clip: true
        }

        onClosed: {
            popupListClosed();
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: locationDelegate

        Rectangle {
            property Location location: index >= 0 ? ListView.view.model.get(index) : null
            property double distance: location ? referenceCoordinate.distanceTo(location.coordinate) : 0
            property double azimuth: location ? referenceCoordinate.azimuthTo(location.coordinate) : 0

            width: ListView.view.width
            height: locationLayout.height + locationLayout.anchors.margins * 2
            color: mouseArea.containsMouse ? "#F0F0F0" : "white"
            radius: 2 * AppFramework.displayScaleFactor

            RowLayout {
                id: locationLayout

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 2 * AppFramework.displayScaleFactor
                }

                Text {
                    Layout.fillWidth: true
                    Layout.minimumHeight: minimumLocationDelegateHeight

                    text: location ? location.address.text : ""
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    verticalAlignment: Text.AlignVCenter
                    color: Singletons.Colors.darkGray

                    font {
                        family: defaultFontFamily
                        pointSize: Singletons.Config.smallFontSizePoint
                    }
                }

                Text {
                    visible: Math.round(distance) > 0
                    text: displayDistance(distance)
                    color: Singletons.Colors.darkGray

                    font {
                        family: defaultFontFamily
                        pointSize: Singletons.Config.xSmallFontSizePoint
                    }
                }
            }

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                height: 1
                color: "#10000000"
            }

            MouseArea {
                id: mouseArea

                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    locationClicked(location);
                }


                onPressAndHold: {
                    locationPressAndHold(location);
                }

                onDoubleClicked: {
                    locationDoubleClicked(location);
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    Timer {
        id: geocodeTimer

        interval: 600
        repeat: false

        onTriggered: {
            geocodeModel.startSearch(textField.text);
        }
    }

    //--------------------------------------------------------------------------

    GeocodeModel {
        id: geocodeModel

        autoUpdate: false
        limit: -1

        onCountChanged: {
             if (geocodeModel.count > 0) {
                 locationPopup.open();
             }
             else {
                 locationPopup.close();
             }
        }

        plugin: Plugin {
            preferred: ["AppStudio"]
        }

        onLocationsChanged: {
            console.log("locationsChanged:", count);
        }

        function startSearch(text) {
            cancel();
            if (text.trim() > "" && text.substr(0, 1) !== '@') {
                query = text.trim();
                update();
            }
        }
    }

    //--------------------------------------------------------------------------

    function clear() {
        console.log("function clear()");
        geocodeTimer.stop();
        geocodeModel.reset();
    }

    //--------------------------------------------------------------------------

    function displayDistance(distance) {
        switch (locale.measurementSystem) {
        case Locale.ImperialUSSystem:
        case Locale.ImperialUKSystem:
            var distanceFt = distance * 3.28084;
            if (distanceFt < 1000) {
                return "%1 ft".arg(Math.round(distanceFt).toLocaleString(locale, "f", 0))
            } else {
                var distanceMiles = distance * 0.000621371;
                return "%1 mi".arg(Math.round(distanceMiles).toLocaleString(locale, "f", distanceMiles < 10 ? 1 : 0))
            }

        default:
            if (distance < 1000) {
                return "%1 m".arg(Math.round(distance).toLocaleString(locale, "f", 0))
            } else {
                var distanceKm = distance / 1000;
                return "%1 km".arg(Math.round(distanceKm).toLocaleString(locale, "f", distanceKm < 10 ? 1 : 0))
            }
        }
    }

    //--------------------------------------------------------------------------

    function parseCoordinate(text) {
        if (!(text > "")) {
            return;
        }

        var a = text.split(",");
        if (a < 2) {
            return;
        }

        var coordinate = QtPositioning.coordinate(a[0], a[1]);

        if (coordinate.isValid) {
            inputCoordinate(coordinate);
        }
    }

    // END /////////////////////////////////////////////////////////////////////
}
