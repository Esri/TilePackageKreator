import QtQuick 2.7
import QtQuick.Controls 2.1
import "../singletons" as Singletons

ComboBox {
    id: control

    font: notoRegular

    onActivated: {
        console.log(currentIndex)
        console.log(model.get(currentIndex)[control.textRole])
    }
    onHighlighted: {
        console.log(currentIndex)
        console.log(model.get(currentIndex)[control.textRole])
    }

    delegate: ItemDelegate {
        width: control.width
        contentItem: Text {
            text: model !== null ? model[control.textRole] : ""
            color: Singletons.Colors.darkGray
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        highlighted: control.highlightedIndex === index
    }

    indicator: Canvas {
        id: canvas
        x: control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 12
        height: 8
        contextType: "2d"

        Connections {
            target: control
            onPressedChanged: canvas.requestPaint()

        }

        onPaint: {
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = Singletons.Colors.mainButtonBackgroundColor
            context.fill();
        }
    }

    contentItem: Text {
        leftPadding: 0
        rightPadding: control.indicator.width + control.spacing

        text: control.model !== null ? control.model.get(control.currentIndex)[control.textRole] : ""
        font.family: notoRegular
        font.pointSize: Singletons.Config.smallFontSizePoint
        color: Singletons.Colors.darkGray
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 40
        border.color: Singletons.Colors.mediumGray
        border.width: control.visualFocus ? 2 : 1
        radius: 2
    }

    popup: Popup {
        y: control.height - 1
        width: control.width
        implicitHeight: contentItem.implicitHeight
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            border.color: Singletons.Colors.mediumGray
            radius: 2
        }
    }


    // END /////////////////////////////////////////////////////////////////////
}
