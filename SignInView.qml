import QtQuick 2.6
import QtQuick.Controls 1.4
import "Portal"

PortalSignInView {

    signal loginSuccess()
    signal loginFailed()

    Stack.onStatusChanged: {
        if(Stack.status === Stack.Deactivating){
            mainView.appToolBar.toolBarTitleLabel = "";
        }
        if(Stack.status === Stack.Activating){
            console.log("activationg")
            mainView.appToolBar.backButtonEnabled = false
            mainView.appToolBar.backButtonVisible = false
            mainView.appToolBar.enabled = false
            mainView.appToolBar.toolBarTitleLabel = "<strong style='font-size:large'>%1</strong> <span style='font-size:small;'>v%2.%3.%4</span>".arg(app.info.title).arg(app.info.value("version").major).arg(app.info.value("version").minor).arg(app.info.value("version").micro)
        }
    }

    portal: portal
    settings: portal.settings
    settingsGroup: portal.settingsGroup
    dialogStyle: false

    onAccepted: {
        loginSuccess();
    }

    onRejected: {
        loginFailed();
    }
}

