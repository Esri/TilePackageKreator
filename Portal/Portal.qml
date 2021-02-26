/* Copyright 2015 Esri
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

import ArcGIS.AppFramework 1.0


Item {
    id: _portal

    readonly property url kDefaultPortalUrl: "https://www.arcgis.com"

    property string name: "ArcGIS Online"
    property url portalUrl: kDefaultPortalUrl
    property url tokenServicesUrl
    property url owningSystemUrl: portalUrl
    readonly property url restUrl: owningSystemUrl + "/sharing/rest"
    property string username
    property string password
    property string token
    property bool ssl: false
    property bool ignoreSslErrors: false
    property date expires
    readonly property bool signedIn: token > "" && info != null && user !== null
    property int expiryMode: expiryModeRefresh
    property bool isPortal
    property bool busy: false
    property bool isBusy: false
    property bool clientMode: true
    property bool canPublish: false
    property bool supportsOAuth: true
    property string currentVersion

    property Settings settings
    property string settingsGroup: "Portal"

    readonly property int expiryModeSignal: 0
    readonly property int expiryModeSignOut: 1
    readonly property int expiryModeSignIn: 2
    readonly property int expiryModeRefresh: 3
    readonly property int defaultExpiration: 120
    property var info: null
    property var user: null
    //    property url userThumbnailUrl: user ? restUrl + "/community/users/" + username + "/info/" + user.thumbnail + "?token=" + token : "images/user.png"
    property url userThumbnailUrl: (token > "" && user && user.thumbnail) ? restUrl + "/community/users/" + username + "/info/" + user.thumbnail + "?token=" + token : "images/user.png"


    property string redirectUri: "urn:ietf:wg:oauth:2.0:oob"
    property string authorizationCode: ""
    readonly property string authorizationEndpoint: portalUrl + "/sharing/rest/oauth2/authorize/"
    property LocaleInfo localeInfo: AppFramework.localeInfo(Qt.locale().uiLanguages[0])
    readonly property string authorizationUrl: authorizationEndpoint + "?client_id=" + clientId + "&grant_type=code&response_type=code&expiration=-1&redirect_uri=" + redirectUri + "&locale=" + localeInfo.esriName
    property string clientId: ""
    property string refreshToken: ""
    property date lastLogin
    property date lastRenewed

    property string signInReason

    property App app
    property string userAgent

    signal expired()
    signal error(var error)
    signal credentialsRequest()

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        userAgent = buildUserAgent(app);
        readSettings();
    }

    //--------------------------------------------------------------------------

    onPortalUrlChanged: {
        //signOut(true);
    }

    //--------------------------------------------------------------------------

    function signIn(reason, prompt) {

        signInReason = reason || ""

        console.log("signIn:", signInReason)

        if (!prompt && canAutoSignIn()) {
            autoSignIn();
        } else {
            credentialsRequest();
        }
    }

    function signOut(reset) {
        console.log("signOut");
        token = "";
        user = null;
        canPublish = false;

        if (reset) {
            tokenServicesUrl = "";
        }
    }

    onSignedInChanged: {
        busy = false;
    }

    //--------------------------------------------------------------------------

    function setUser(user, pass) {
        username = user;
        password = pass;

        if (!AppFramework.network.isOnline) {
            return;
        }

        console.log("setUser:", username);

        busy = true;

        if (tokenServicesUrl > "") {
            generateToken.generateToken(username, password);
        } else {
            infoRequest.headers.userAgent = _portal.userAgent;
            infoRequest.send();
        }
    }

    //--------------------------------------------------------------------------

    function setAuthorizationCode(authorizationCode) {
        busy = true;
        getTokenFromCode(clientId, redirectUri, authorizationCode);
    }

    function setRefreshToken(token) {
        refreshToken = token;

        if (refreshToken > "") {
            busy = true;
            getTokenFromRefreshToken(clientId, refreshToken);
        }
    }

    //--------------------------------------------------------------------------

    readonly property string keyRefreshToken: "/refreshToken"
    readonly property string keyDateSaved: "/dateSaved"

    function canAutoSignIn() {
        if (!settings) {
            return false;
        }

        if (!supportsOAuth) {
            return false;
        }

        var refreshToken = settings.value(settingsGroup + keyRefreshToken,"")

        return refreshToken > "";
    }

    function autoSignIn() {
        if (!AppFramework.network.isOnline) {
            return;
        }

        if (!settings) {
            return;
        }

        console.log("Portal:: Trying to auto-sign-in ...");

        readSettings();

        var refreshToken = settings.value(settingsGroup + keyRefreshToken,"")
        var dateSaved = settings.value(settingsGroup + keyDateSaved,"")

        lastLogin = dateSaved > "" ? new Date(dateSaved) : new Date()

        console.log("Portal:: Getting saved OAuth info: ", dateSaved, refreshToken);

        if (refreshToken > "") {
            console.log("Portal:: Found stored info, getting token now ...");
            getTokenFromRefreshToken(clientId, refreshToken);
        }
    }

    function writeSignedInState() {
        if (!settings) {
            return;
        }

        console.log("Storing signed in values:", settingsGroup);

        settings.setValue(settingsGroup + keyRefreshToken, portal.refreshToken);
        settings.setValue(settingsGroup + keyDateSaved, new Date().toString());

        writeUserSettings();
    }

    function clearSignedInState() {
        if (!settings) {
            return;
        }

        console.log("Clearing signed in values:", settingsGroup);

        settings.remove(settingsGroup + keyRefreshToken);
        settings.remove(settingsGroup + keyDateSaved);
        settings.remove(settingsGroup + "/password");
    }

    //--------------------------------------------------------------------------

    function autoLogin() {
        console.log("Portal:: Trying to auto-sign-in ...");

        if (localStorage) {
            var client_id = localStorage.value(settingsGroup + "/client_id","")
            var refresh_token = localStorage.value(settingsGroup + "/refresh_token","")
            var date_saved = localStorage.value(settingsGroup + "/date_saved","")

            _portal.lastLogin = date_saved > "" ? new Date(date_saved) : new Date()

            console.log("Portal:: Getting saved OAuth info: ", client_id, date_saved, refresh_token);

            if(client_id > "" && refresh_token > "") {
                console.log("Portal:: Found stored info, getting token now ...");
                _portal.getTokenFromRefreshToken(client_id, refresh_token);
            }
        }
    }

    function getTokenFromCode(client_id, redirect_uri, auth_code) {
        if(auth_code > "" && client_id > "") {
            _portal.isBusy = true;
            _portal.refreshToken = "";
            _portal.clientId = client_id;

            var params = {};
            params.grant_type = "authorization_code";
            params.client_id = client_id;
            params.code = auth_code;
            params.redirect_uri = redirect_uri;
            timer.stop();

            oAuthAccessTokenFromAuthCodeRequest.headers.userAgent = _portal.userAgent;
            oAuthAccessTokenFromAuthCodeRequest.send(params);
        }
    }

    function getTokenFromRefreshToken(client_id, refresh_token) {
        if(refresh_token > "" && client_id > "") {
            _portal.isBusy = true;
            _portal.refreshToken = refresh_token;
            _portal.clientId = client_id;

            var params = {};
            params.grant_type = "refresh_token";
            params.client_id = client_id;
            params.refresh_token = refresh_token;
            timer.stop();

            oAuthAccessTokenFromAuthCodeRequest.headers.userAgent = _portal.userAgent;
            oAuthAccessTokenFromAuthCodeRequest.send(params);
        }
    }

    function renew() {
        console.log("!!! Inside portal renew !!!");
        console.log(_portal.refreshToken, _portal.clientId)
        if (_portal.refreshToken > "" && _portal.clientId > "") {
            getTokenFromRefreshToken(_portal.clientId, _portal.refreshToken)
        }
        else {
            signOut();
        }
    }

    NetworkRequest {
        id: oAuthAccessTokenFromAuthCodeRequest

        url: portalUrl + "/sharing/rest/oauth2/token"
        responseType: "json"
        ignoreSslErrors: _portal.ignoreSslErrors

        onReadyStateChanged: {
            if (readyState === NetworkRequest.ReadyStateComplete)
            {
                console.log("oauth token info:", JSON.stringify(response, undefined, 2));

                if (response.refresh_token) {
                    _portal.refreshToken = response.refresh_token;
                }
                _portal.username = response.username || "";
                _portal.token = response.access_token || "";

                var now = new Date();
                _portal.lastRenewed = now;
                _portal.expires = new Date(now.getTime() + response.expires_in*1000);
                console.log("Token expires at : ", expires.toLocaleString());

                timer.interval = _portal.expires - Date.now() - 5000;
                timer.start();

                _portal.isBusy = false;

                versionRequest.headers.userAgent = _portal.userAgent;
                versionRequest.send();
                selfRequest.sendRequest();
                userRequest.sendRequest();
            }
        }

        onErrorTextChanged: {
            _portal.isBusy = false;
            console.log("oAuthAccessTokenRequest error", errorText);
        }
    }


    //--------------------------------------------------------------------------

    Timer {
        id: timer

        onTriggered: {
            switch (expiryMode) {
            case expiryModeSignIn:
                signIn();
                break;

            case expiryModeSignOut:
                signOut();
                break;

            case expiryModeRefresh:
                renew();
                break;

            default:
                expired();
                break;
            }
        }
    }

    //--------------------------------------------------------------------------

    NetworkRequest {
        id: infoRequest

        url: portalUrl + "/sharing/rest/info?f=json"
        responseType: "json"
        ignoreSslErrors: portal.ignoreSslErrors

        onReadyStateChanged: {
            if (readyState === NetworkRequest.ReadyStateComplete)
            {
                //console.log("info:", JSON.stringify(response, undefined, 2));

                tokenServicesUrl = response.authInfo.tokenServicesUrl;
                owningSystemUrl = response.owningSystemUrl;
                generateToken.generateToken(_portal.username, _portal.password);
            }
        }

        onErrorTextChanged: {
            console.log("infoRequest error", errorText);
        }
    }

    NetworkRequest {
        id: generateToken

        url: tokenServicesUrl
        method: "POST"
        responseType: "json"
        ignoreSslErrors: portal.ignoreSslErrors
        uploadPrefix: ""

        onReadyStateChanged: {
            if (readyState === NetworkRequest.ReadyStateComplete)
            {
                if (response.error) {
                    portal.error(response.error);
                } else if (response.token) {
                    console.log("username", username, "generateToken:", JSON.stringify(response, undefined, 2));
                    token = response.token;
                    expires = new Date(response.expires);
                    ssl = response.ssl;
                    timer.interval = expires - Date.now() - 5000;
                    timer.start();
                    console.log("expires", expires, timer.interval / 3600000, "hours");

                    // Adjusting our URLS to be SSL-only based on the SSL property obtained from getToken call

                    if (ssl) {
                        portalUrl = httpsUrl(portalUrl);
                        owningSystemUrl = httpsUrl(owningSystemUrl);
                    }

                    versionRequest.headers.userAgent = _portal.userAgent;
                    versionRequest.send();
                    selfRequest.sendRequest();
                    userRequest.sendRequest();
                } else {
                    //
                }
            }
        }

        onErrorTextChanged: {
            portal.error( { message: errorText, details: "" });
            console.log("generateToken error", errorText);
        }

        function httpsUrl(url) {
            var urlInfo = AppFramework.urlInfo(url);

            urlInfo.scheme = "https";

            console.log("httpsUrl", url, "->", urlInfo.url);

            return urlInfo.url;
        }

        function generateToken(username, password, expiration, referer) {

            if (!expiration) {
                expiration = defaultExpiration;
            }

            if (!referer) {
                referer = portalUrl;
            }

            var formData = {
                "username": username,
                "password": password,
                "referer": referer,
                "expiration": expiration,
                "f": "json"
            };

            headers.userAgent = _portal.userAgent;
            send(formData);
        }
    }

    NetworkRequest {
        id: selfRequest

        url: restUrl + "/portals/self"
        method: "POST"
        responseType: "json"
        ignoreSslErrors: portal.ignoreSslErrors

        onReadyStateChanged: {
            if (readyState === NetworkRequest.ReadyStateComplete)
            {
                //console.log("portal self:", JSON.stringify(response, undefined, 2));
                portal.info = response;
                if (portal.info && portal.info.allSSL) {
                    ssl = portal.info.allSSL;
                }
            }
        }

        onErrorTextChanged: {
            console.log("selfRequest error", errorText);
        }

        function sendRequest() {
            var formData = {
                f: "pjson"
            };

            if (portal.token > "") {
                formData.token = portal.token;
            }

            headers.userAgent = _portal.userAgent;
            send(formData);
        }
    }

    //--------------------------------------------------------------------------

    NetworkRequest {
        id: versionRequest

        url: restUrl + "?f=json"
        responseType: "json"

        onReadyStateChanged: {
            if (readyState === NetworkRequest.ReadyStateComplete)
            {
                if (response.currentVersion) {
                    currentVersion = response.currentVersion;
                    console.log("Portal currentVersion:", currentVersion);
                } else {
                    console.error("Invalid version response:", JSON.stringify(response, undefined, 2));
                }
            }
        }

        onErrorTextChanged: {
            console.error("versionRequest error", errorText);
        }
    }

    //--------------------------------------------------------------------------


    NetworkRequest {
        id: userRequest

        url: restUrl + "/community/users/" + username
        method: "POST"
        responseType: "json"
        ignoreSslErrors: portal.ignoreSslErrors

        onReadyStateChanged: {
            if (readyState === NetworkRequest.ReadyStateComplete)
            {
                //console.log("user", JSON.stringify(response, undefined, 2));

                if (response.error) {
                    clearSignedInState();
                    portal.error(response.error);
                    return;
                }

                portal.user = response;

                //Need to handle three usecases
                //1. Public Account Free user (no ORG ID) #242
                //2. Survey123 client app needs atleast feature editing permissions #new
                //3. Survey123 Connect app needs atleast 3 permission #154

                var privileges = response.privileges;
                var canPublish = false;
                var canShare = false;
                var canCreate = false;
                var canEdit = false;

                for (var i in privileges) {
                    //console.log(privileges[i]);

                    if (privileges[i] === "portal:publisher:publishFeatures") {
                        canPublish = true;
                    }

                    if (privileges[i] === "portal:user:createItem") {
                        canCreate = true;
                    }

                    if (privileges[i] === "portal:user:shareToGroup") {
                        canShare = true;
                    }

                    if (privileges[i] === "features:user:edit") {
                        canEdit = true
                    }
                }

                if (clientMode) {
                    if (!canEdit) {
                        console.log("Insufficient Client Privileges");

                        var clientErr = {
                            message: qsTr("Insufficient Client Privileges"),
                            details: qsTr("Need minimum privileges of Features Edit in your Role. Please contact your ArcGIS Administrator to resolve this issue.")
                        }

                        portal.error(clientErr);
                        portal.signOut();
                    }
                } else {
                    //this is the connect app and need more privileges
                    if (!canCreate || !canPublish || !canShare) {
                        //need to alert that this account does not have sufficient privileges
                        console.log("Insufficient Privileges")

                        var err = {
                            message: qsTr("Insufficient Client Privileges"),
                            details: qsTr("Need minimum privileges of Create content, Publish hosted feature layers and Share with groups in your Role. Please contact your ArcGIS Administrator to resolve this issue.")
                        }

                        portal.canPublish = false
                        portal.error(err);
                        portal.signOut();
                    } else {
                        portal.canPublish = true
                    }

                }

                if (token) {
                    portal.user = response;

                    //Use default user icon if thumbnail is not set in users profile
                    if (!portal.user.thumbnail) {
                        portal.userThumbnailUrl = app.folder.fileUrl("template/images/user.png")
                    }
                }
            }
        }

        onErrorTextChanged: {
            console.log("userRequest error", errorText);
        }

        function sendRequest() {
            var formData = {
                f: "pjson"
            };

            if (portal.token > "") {
                formData.token = portal.token;
            }

            headers.userAgent = _portal.userAgent;
            send(formData);
        }
    }

    //--------------------------------------------------------------------------

    function readSettings() {
        if (!settings) {
            return false;
        }

        portalUrl = settings.value(settingsGroup + "/url", "https://www.arcgis.com");
        name = settings.value(settingsGroup + "/name", "ArcGIS Online");
        ignoreSslErrors = settings.boolValue(settingsGroup + "/ignoreSslErrors", false);
        isPortal = settings.boolValue(settingsGroup + "/isPortal", false);
        supportsOAuth = settings.boolValue(settingsGroup + "/supportsOAuth", true);

        console.log("Read portal settings:", name, portalUrl, "isPortal", isPortal, "ignoreSslErrors", ignoreSslErrors, "supportsOAuth", supportsOAuth);

        readUserSettings();

        return true;
    }

    function writeSettings() {
        if (!settings) {
            return false;
        }

        console.log("Write portal settings:", name, portalUrl, "isPortal", isPortal, "ignoreSslErrors", ignoreSslErrors, "supportsOAuth", supportsOAuth);

        settings.setValue(settingsGroup + "/url", portalUrl);
        settings.setValue(settingsGroup + "/name", name);
        settings.setValue(settingsGroup + "/ignoreSslErrors", ignoreSslErrors);
        settings.setValue(settingsGroup + "/isPortal", isPortal);
        settings.setValue(settingsGroup + "/supportsOAuth", supportsOAuth);

        return true;
    }

    //--------------------------------------------------------------------------

    function readUserSettings() {
        if (!settings) {
            return false;
        }

        //        saveUserChecked = settings.boolValue(settingsGroup + "/saveUsername", true);
        username = settings.value(settingsGroup + "/username", "");
        //        if (autoSignIn) {
        //            password = rot13(settings.value(settingsGroup + "/password", ""));
        //        }

        return true;
    }

    function writeUserSettings() {
        if (!settings) {
            return false;
        }

        settings.setValue(settingsGroup + "/username", portal.username);

        //        if (autoSignIn) {
        //            settings.setValue(settingsGroup + "/password", rot13(portal.password));
        //        } else {
        //            settings.remove(settingsGroup + "/password");
        //        }
    }

    function clearUserSettings() {
        if (!settings) {
            console.warn("clearUserSettings: Sign In settings not persisted");
            return false;
        }

        console.log("Clearing user credentials");

        settings.remove(settingsGroup + "/username");
        settings.remove(settingsGroup + "/password");
    }

    function rot13(s) {
        return s.replace(/[A-Za-z]/g, function (c) {
            return "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".charAt(
                        "NOPQRSTUVWXYZABCDEFGHIJKLMnopqrstuvwxyzabcdefghijklm".indexOf(c)
                        );
        } );
    }

    //--------------------------------------------------------------------------

    function buildUserAgent(app) {
        var userAgent = "";

        function addProduct(name, version, comments) {
            if (!(name > "")) {
                return;
            }

            if (userAgent > "") {
                userAgent += " ";
            }

            name = name.replace(/\s/g, "");
            userAgent += name;

            if (version > "") {
                userAgent += "/" + version.replace(/\s/g, "");
            }

            if (comments) {
                userAgent += " (";

                for (var i = 2; i < arguments.length; i++) {
                    var comment = arguments[i];

                    if (!(comment > "")) {
                        continue;
                    }

                    if (i > 2) {
                        userAgent += "; "
                    }

                    userAgent += arguments[i];
                }

                userAgent += ")";
            }

            return name;
        }

        function addAppInfo(app) {
            var deployment = app.info.value("deployment");
            if (!deployment || typeof deployment !== 'object') {
                deployment = {};
            }

            var appName = deployment.shortcutName > ""
                    ? deployment.shortcutName
                    : app.info.title;

            var udid = app.settings.value("udid", "");

             if (!(udid > "")) {
                    udid = AppFramework.createUuidString(2);
                    app.settings.setValue("udid", udid);
            }

            appName = addProduct(appName, app.info.version, Qt.locale().name, AppFramework.currentCpuArchitecture, udid)

            return appName;
        }

        if (app) {
            addAppInfo(app);
        } else {
            addProduct(Qt.application.name, Qt.application.version, Qt.locale().name, AppFramework.currentCpuArchitecture, Qt.application.organization);
        }

        addProduct(Qt.platform.os, AppFramework.osVersion, AppFramework.osDisplayName);
        addProduct("AppFramework", AppFramework.version, "Qt " + AppFramework.qtVersion, AppFramework.buildAbi);
        addProduct(AppFramework.kernelType, AppFramework.kernelVersion);

        // console.log("userAgent:", userAgent);

        return userAgent;
    }

    //--------------------------------------------------------------------------
}
