import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
//------------------------------------------------------------------------------
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
//------------------------------------------------------------------------------

Rectangle{

    // PROPERTIES //////////////////////////////////////////////////////////////

    id: mapDrawingToolMenu

    width: (parent.width < 700) ? parent.width - 20 * AppFramework.displayScaleFactor : 500 * AppFramework.displayScaleFactor
    height: 58 * AppFramework.displayScaleFactor
    color: "white"
    radius: 5 * AppFramework.displayScaleFactor
    opacity: (!drawing) ? 1 : .4

    property int buttonWidth: /*180*/ 50 * AppFramework.displayScaleFactor

    property bool drawing: false
    property bool drawingExists: false
    property string activeGeometryType: ""

    signal drawingRequest(string g)

    // UI //////////////////////////////////////////////////////////////////////

    RowLayout{
        anchors.fill: parent
        anchors.margins: 4 * AppFramework.displayScaleFactor
        anchors.rightMargin: 6 * AppFramework.displayScaleFactor
        spacing:0

        Rectangle{
            id: infoBar
            readonly property var success: {
                "backgroundColor": "#DDEEDB",
                "borderColor": "#9BC19C"
            }

            readonly property var info: {
                "backgroundColor": "#D2E9F9",
                "borderColor": "#3B8FC4"
            }

            readonly property var warning: {
                "backgroundColor": "#F3EDC7",
                "borderColor": "#D9BF2B"
            }

            readonly property var error: {
                "backgroundColor": "#F3DED7",
                "borderColor": "#E4A793"
            }
            Layout.fillHeight: true
            Layout.preferredWidth: 200 * AppFramework.displayScaleFactor

            RowLayout{
                anchors.fill: parent
                spacing: 0
                Rectangle{
                    color: "transparent"
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.height - (10 * AppFramework.displayScaleFactor)
                    Layout.rightMargin: 10 * AppFramework.displayScaleFactor

                    Text {
                        anchors.centerIn: parent
                        font.pointSize: config.largeFontSizePoint * 1.2
                        font.family: icons.name
                        text: (!drawing) ? ( (!drawingExists) ? icons.warning : icons.checkmark ) : icons.happy_face
                    }
                }
                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    Text {
                        id: drawingNotice
                        anchors.fill: parent
                        font.family: notoRegular.name
                        verticalAlignment: Text.AlignVCenter
                        text: (!drawing) ? ( (!drawingExists) ? qsTr("Draw an extent or path") : qsTr("Extent / Path Drawn") ) : (activeGeometryType === "envelope") ? qsTr("Drawing Extent") : qsTr("Drawing Path")
                    }
                }
            }
        }

        Rectangle{
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Rectangle{
            id: buttonContainer
            Layout.fillHeight: true
            Layout.preferredWidth: buttonWidth * drawingTypesModel.count
            color: "transparent"
            ListView{
                anchors.fill: parent
                model: drawingTypesModel
                delegate: drawingButtonComponent
                spacing: 2 * AppFramework.displayScaleFactor
                layoutDirection: Qt.LeftToRight
                orientation: ListView.Horizontal
            }
        }
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    ListModel{

        id: drawingTypesModel

        ListElement{
            name: qsTr("Draw Rectangle")
            property bool available: true
            property string geometryType: "envelope"
            property url iconPath: "images/draw_extent.png"
            property string fontIcon: "draw_extent"
        }

        ListElement{
            name: qsTr("Draw Path")
            property bool available: true
            property string geometryType: "multipath"
            property url iconPath: "images/draw_path.png"
            property string fontIcon: "draw_path"
        }

    }

    //--------------------------------------------------------------------------

    Component{
        id: drawingButtonComponent

        Rectangle{
            width: buttonWidth
            height: parent.height
            color: "transparent"

            Button {
                anchors.fill: parent
                enabled: available
                visible: available
                property string g: geometryType
                tooltip: name

                style: ButtonStyle {
                    background: Rectangle {
                        anchors.fill: parent
                        color: (control.enabled) ? ( (control.pressed) ? "#bddbee" : "#fff" ) : (activeGeometryType === geometryType) ? app.info.properties.mainButtonBorderColor : "#eee"
                        border.width: (control.enabled) ? app.info.properties.mainButtonBorderWidth : 0
                        border.color: (control.enabled) ? app.info.properties.mainButtonBorderColor : "#ddd"
                        radius: 3 * AppFramework.displayScaleFactor
                    }
                }

                RowLayout{
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.height
                        color: "transparent"

                        Text{
                            anchors.centerIn: parent
                            font.pointSize: config.largeFontSizePoint * 1.5
                            color: (activeGeometryType === geometryType) ? "#fff" : app.info.properties.mainButtonBorderColor
                            font.family: icons.name
                            text: icons[fontIcon]
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        visible: false
                        Text {
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: app.info.properties.mainButtonBorderColor
                            textFormat: Text.RichText
                            text: name
                            font.pointSize: config.baseFontSizePoint
                            font.family: notoRegular.name
                        }
                    }
                }

                onClicked: {
                    drawing = true;
                    drawingRequest(g);
                    activeGeometryType = g;
                }
            }
        }
    }

    // METHODS /////////////////////////////////////////////////////////////////

    function drawingRequestComplete(){
        drawing = false;
        activeGeometryType = "";
    }

    // END /////////////////////////////////////////////////////////////////////
}
