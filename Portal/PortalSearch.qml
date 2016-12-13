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

import QtQuick 2.4
import QtLocation 5.0

import ArcGIS.AppFramework 1.0

PortalRequest {
    id: searchRequest
    
    property int num: 10
    property string q
    property string sortField
    property string sortOrder
    property MapRectangle bbox

    readonly property real searchProgress: total > 0 ? Math.min(1, count / total) : -1
    property int count: 0
    property int total: -1
    property bool debug: false
    
    url: portal ? portal.restUrl + "/search" : ""
    
    //--------------------------------------------------------------------------

    function search(start) {
        if (start < 0) {
            return;
        }

        if (!start) {
            start = 1;
        }

        if (start == 1) {
            count = 0;
            total = -1;
        }

        var formData = {
            "q": q,
            "start": start,
            "num": num
        };
        
        if (bbox) {
            formData.bbox = bbox.topLeft.longitude.toString() + "," +
                    bbox.bottomRight.latitude.toString() + "," +
                    bbox.bottomRight.longitude.toString() + "," +
                    bbox.topLeft.latitude.toString();
        }
        
        if (sortField > "") {
            formData.sortField = sortField;
        }
        
        if (sortOrder > "") {
            formData.sortOrder = sortOrder;
        }
        
        if (debug) {
            console.log("Portal search from index:", start, "q:", q);
        }

        searchRequest.sendRequest(formData);
    }

    //--------------------------------------------------------------------------

    onSuccess: {
        if (response.total) {
            total = response.total;
        }

        if (response.num) {
            count = Math.min(total, count + response.num);
        }

        if (debug) {
//            console.log("searchResponse:", JSON.stringify(response, undefined, 2));
            console.log("Search response: total:", response.total, "start:", response.start, "num:", response.num, "nextStart:", response.nextStart);
            console.log("Search progress:", searchProgress);
        }
    }

    //--------------------------------------------------------------------------
}
