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

import QtQuick 2.5
import QtLocation 5.3
import QtPositioning 5.3
//------------------------------------------------------------------------------
import "../Portal"

Item {
    id: mapView

    property Portal portal
    property url mapService
    property bool useToken
    property bool mapLoaded: mapLoader.status === Loader.Ready

    readonly property Map map: mapLoader.item
    property var defaultCenter: { "lat":0, "long":0 }
    property int defaultZoomLevel: 10

    property var currentCenter: null
    property int currentZoomLevel: -1
    property var lastKnownCenter: null
    property int lastKnownZoomLevel: -1

    signal zoomLevelChanged(var level)
    signal mapPanningFinished()
    signal mapPanningStarted()
    signal mapItemsCleared()
    signal mapCenterChanged(var center)

    Loader {
        id: mapLoader

        anchors.fill: parent

        active: false
        sourceComponent: mapComponent
    }

    QtObject {
        id: internal

        property var mapSources: []
    }

    Component {
        id: mapComponent

        Map {
            id: baseMap
            plugin: Plugin {
                preferred: ["AppStudio"]

                PluginParameter {
                    name: "ArcGIS.token"
                    value: (useToken) ? portal.token : ""
                }

                PluginParameter {
                    name: "ArcGIS.mapping.mapTypes.append"
                    value: false
                }

                PluginParameter {
                    name: "ArcGIS.mapping.mapTypes.mapSources"
                    value: internal.mapSources
                }
            }

            center: QtPositioning.coordinate(defaultCenter.lat,defaultCenter.long)
            zoomLevel: defaultZoomLevel
            gesture.enabled: true

            gesture.onPanStarted: {
                mapView.mapPanningStarted();
            }

            gesture.onPanFinished: {
                mapView.mapPanningFinished();
            }

            gesture.onFlickStarted: {
                console.log('flick started');
            }
            gesture.onPinchStarted: {
                console.log('pinch started');
            }

            Component.onCompleted: {
                clearData();
            }

            onZoomLevelChanged: {
                mapView.zoomLevelChanged(baseMap.zoomLevel);
                currentZoomLevel = baseMap.zoomLevel;
            }

            onCenterChanged: {
                currentCenter = baseMap.center;
            }

            onMapItemsChanged: {
                if(mapItems.length === 0){
                    mapItemsCleared();
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    onMapServiceChanged: {
        lastKnownCenter = currentCenter !== null ? currentCenter : null;
        lastKnownZoomLevel = currentZoomLevel !== -1 ? currentZoomLevel : -1
        update();
    }

    onMapItemsCleared: {
        console.log('all map items removed');
    }

    onMapLoadedChanged: {
        if (mapLoaded) {
            if (lastKnownCenter !== null && lastKnownZoomLevel > -1) {
                map.center = lastKnownCenter;
                map.zoomLevel = lastKnownZoomLevel > map.maximumZoomLevel ? map.maximumZoomLevel : lastKnownZoomLevel;
            }
        }
    }

    Connections {
        target: portal

        onTokenChanged: {
            reset();
        }
    }

    //--------------------------------------------------------------------------

    function update() {
        var mapSources = [
                    {
                        url: mapService + "/tile/${z}/${y}/${x}?token=${token}"
                    }
                ];

        internal.mapSources = mapSources;
        reset();
    }

    //--------------------------------------------------------------------------

    function reset() {
        mapLoader.active = false;
        mapLoader.active = true;
    }

    // END /////////////////////////////////////////////////////////////////////
}
