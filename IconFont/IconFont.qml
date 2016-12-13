import QtQuick 2.0

FontLoader{

    // ttf font file created with https://icomoon.io

    source: "fonts/tilepackagekreator.ttf"

    property string chat_bubble: "\ue96e"
    property string checkmark: "\uea10"
    property string chevron_left: "\uf053"
    property string chevron_right: "\uf054"

    property string download: "\ue9c7"
    property string download_circle: "\uf01a"
    property string draw_extent: "\ue900"
    property string draw_path: "\ue901"

    property string happy_face: "\ue9df"
    property string history: "\ue94d"

    property string info: "\uea0c"

    property string loop: "\uea2e"

    property string minus_sign: "\uea0b"

    property string plus_sign: "\uea0a"

    property string question: "\uea09"

    property string sad_face: "\ue9e5"
    property string search: "\ue986"
    property string sign_out: "\ue902"
    property string spinner: "\ue982"
    property string spinner2: "\ue97d"
    property string spinner3: "\ue983"

    property string trash_bin: "\ue983"

    property string upload: "\ue9c8"
    property string user: "\ue971"

    property string warning: "\uea07"

    property string x_cross: "\uea0f"

    //--------------------------------------------------------------------------

    function getIconByName(name){
        return this[name];
    }

}
