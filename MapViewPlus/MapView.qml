import QtQuick 2.5
import QtLocation 5.3
import QtPositioning 5.3

import "../Portal"

Item {
    id: mapView

    property Portal portal
    property url mapService
    property bool useToken

    readonly property Map map: mapLoader.item
    property var defaultCenter: { "lat":0, "long":0 }
    property int defaultZoomLevel: 10
    signal zoomLevelChanged(var level)
    signal mapPanningFinished()
    signal mapPanningStarted()
    signal mapItemsCleared()

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
            id:baseMap
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
                console.log(mapService);
                clearData();
            }

            onZoomLevelChanged: {
                mapView.zoomLevelChanged(baseMap.zoomLevel);
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
        update();
    }

    onMapItemsCleared: {
        console.log('all map items removed');
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
