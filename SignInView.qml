/* Copyright 2021 Esri
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

import QtQuick 2.15
import QtQuick.Controls 2.15
//------------------------------------------------------------------------------
import "Portal"
//------------------------------------------------------------------------------

PortalSignInView {

    signal loginSuccess()
    signal loginFailed()

    StackView.onActivating: {
        console.log("activationg")
        mainView.appToolBar.backButtonEnabled = false
        mainView.appToolBar.backButtonVisible = false
        mainView.appToolBar.enabled = false
        mainView.appToolBar.toolBarTitleLabel = "<strong style='font-size:large'>%1</strong> <span style='font-size:small;'>v%2.%3.%4</span>".arg(app.info.title).arg(app.info.value("version").major).arg(app.info.value("version").minor).arg(app.info.value("version").micro)
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

