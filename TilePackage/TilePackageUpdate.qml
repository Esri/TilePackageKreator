import QtQuick 2.0
import QtQuick.Dialogs 1.2
import ArcGIS.AppFramework 1.0
import "../Portal"

Item {

    id: tpkUpdate

    // PROPERTIES //////////////////////////////////////////////////////////////

    property Portal portal

    property bool active

    signal updated()
    signal shared(string itemId)
    signal error(string err)
    signal cancelled(string response)

    // METHODS /////////////////////////////////////////////////////////////////

    function update(itemId, params){

        active = true;

        var itemInfo = {};

        for(var p in params){
            itemInfo[p] = params[p];
        }

        updateRequest.itemId = itemId;
        updateRequest.requestType = "update"
        updateRequest.send(itemInfo);
    }

    //--------------------------------------------------------------------------

    function share(itemId, param /* "org" || "everyone" || "groups" */){

        active = true;

        var itemInfo = {
            "f": "pjson",
            "token": portal.token
        };

        itemInfo[param] = true;

        //itemInfo["token"] = portal.token;
        //itemInfo.f = "pjson";
        //itemInfo["User-Agent"] = app.userAgent;

        updateRequest.itemId = itemId;
        updateRequest.requestType = "share"
        updateRequest.send(itemInfo);
    }

    //--------------------------------------------------------------------------

    function cancel(){
        if(active){
            updateRequest.abort();
        }
    }

    // SIGNAL IMPLEMENTATIONS //////////////////////////////////////////////////

    onError: {
        console.log('TPKUpdate error');
        active = false;
    }

    onCancelled:{
        console.log('TPKUpdate cancelled');
        active = false;
    }

    onUpdated: {
        console.log('TPKUpdate updated');
        active = false;
    }

    onShared: {
        console.log("TPKUpdate > shared");
        active = false;
    }

    // COMPONENTS //////////////////////////////////////////////////////////////

    NetworkRequest {

        id: updateRequest

        property string itemId
        property string requestType
        property url userContentUrl: tpkUpdate.portal.restUrl + "/content/users/" + tpkUpdate.portal.username

        signal success();
        signal failed(var error)

        responseType: "json"
        method: "POST"
        headers.userAgent: tpkUpdate.portal.userAgent

        url: userContentUrl +  "/items/" + itemId + "/" + requestType

        ignoreSslErrors: tpkUpdate.portal && tpkUpdate.portal.ignoreSslErrors

        headers {
            referrer: tpkUpdate.portal.portalUrl
        }

        onReadyStateChanged: {

            if (readyState === NetworkRequest.ReadyStateComplete) {

                if (status === 200) {
                     if (response.error) {
                        console.log('update error');
                        tpkUpdate.error(response.error)
                    }
                    else {
                         console.log('update success');

                        tpkUpdate.shared(this.itemId);
                    }
                }
                else {
                    if(status !== 0){
                        tpkUpdate.error("status is %1".arg(status.toString()));
                    }
                }
            }
        }

        onErrorTextChanged: {
            //if(errorText.indexOf("Operation canceled") > -1){
                //tpkUpdate.failed({"code":0, "message": errorText});
            //}
        }

    }

    // END /////////////////////////////////////////////////////////////////////
}
