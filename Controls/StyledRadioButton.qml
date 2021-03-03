import QtQuick 2.15
import QtQuick.Controls 2.15
import "../singletons" as Singletons

RadioButton {
    id: control
    checked: false
    opacity: enabled ? 1 : .4

    objectName: "ThemeRadioButton"

    property string label: "Radio"
    property bool displayTooltip: false
    property string tooltip: ""
    property bool rtl: false

    ToolTip.visible: displayTooltip && hovered
    ToolTip.text: tooltip

    Accessible.role: Accessible.RadioButton
    Accessible.name: control.text
    Accessible.description: control.text
    Accessible.focusable: true

    indicator: Rectangle {
        width: parent.height - sf(4)
        height: parent.height - sf(4)
        x: sf(2)
        y: sf(2)
        radius: width / 2
        border.color: Singletons.Colors.darkGray
        border.width: sf(1)
        color: "transparent"
        anchors {
            left: !control.rtl ? control.left : undefined
            right: !control.rtl ? undefined : control.right
        }

        Rectangle {
            width: parent.height - sf(8)
            height: parent.height - sf(8)
            x: (parent.width - width) / 2
            y: (parent.width - width) / 2
            radius: height / 2
            color: control.checked ? Singletons.Colors.darkGray : "transparent"
        }
    }

    contentItem: Text {
        text: control.text
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        leftPadding: !control.rtl ? control.indicator.width + sf(1) : 0
        rightPadding: !control.rtl ? 0 : control.indicator.width + sf(1)
        color: Singletons.Colors.darkGray
        font {
            family: defaultFontFamily
            pointSize: Singletons.Config.smallFontSizePoint
        }
    }

    // END /////////////////////////////////////////////////////////////////////
}
