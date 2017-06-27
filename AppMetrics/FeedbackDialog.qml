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
import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

import ArcGIS.AppFramework 1.0
import "../"
import "../singletons" as Singletons


Dialog {

    id: feedbackDialog

    property AppMetrics metrics

    width: 500 * AppFramework.displayScaleFactor
    height: 500 * AppFramework.displayScaleFactor
    modality: Qt.WindowModal
    title: qsTr("Feedback for") + " " + app.info.title

    //--------------------------------------------------------------------------
    contentItem: Rectangle {
        anchors.fill: parent
        anchors.margins: 20 * AppFramework.displayScaleFactor
        anchors.topMargin: 5 * AppFramework.displayScaleFactor
        anchors.bottomMargin: 5 * AppFramework.displayScaleFactor
        color: "#eee"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            //----------------------------------------------------------------------
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40 * AppFramework.displayScaleFactor
                color: Singletons.Config.subtleBackground

                Text {
                    anchors.fill: parent
                    anchors.bottomMargin: 5 * AppFramework.displayScaleFactor
                    text: feedbackDialog.title
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: Singletons.Config.largeFontSizePoint
                    font.family: notoRegular
                    color: Singletons.Config.formElementFontColor
                }
            }

            //----------------------------------------------------------------------
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40 * AppFramework.displayScaleFactor

                RowLayout {
                    anchors.fill: parent
                    anchors.topMargin: 5 * AppFramework.displayScaleFactor
                    anchors.bottomMargin: 5 * AppFramework.displayScaleFactor
                    spacing: 0

                    Text {
                        Layout.preferredWidth: 100 * AppFramework.displayScaleFactor
                        Layout.fillHeight: true
                        textFormat: Text.RichText
                        text: qsTr("Subject") + "<span style:\"color:red\">*</span>"
                        verticalAlignment: Text.AlignVCenter
                        font.family: notoRegular
                    }

                    TextField {
                        id: feedbackSubject
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        placeholderText: qsTr("Enter a subject")
                        style: TextFieldStyle {
                            background: Rectangle {
                                anchors.fill: parent
                                border.width: Singletons.Config.formElementBorderWidth
                                border.color: Singletons.Config.formElementBorderColor
                                radius: Singletons.Config.formElementRadius
                                color: Singletons.Config.formElementBackground
                            }
                            textColor: Singletons.Config.formElementFontColor
                            font.family: notoRegular

                        }
                        onTextChanged: {
                             if(text.length > 0 && feedbackMessage.text.length > 0){
                                    sendFeedbackBtn.enabled = true;
                             }
                             else{
                                 sendFeedbackBtn.enabled = false;
                             }
                        }
                    }
                }
            }


            //----------------------------------------------------------------------
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                RowLayout {
                    anchors.fill: parent
                    anchors.topMargin: 5 * AppFramework.displayScaleFactor
                    anchors.bottomMargin: 5 * AppFramework.displayScaleFactor
                    spacing: 0

                    Text {
                        Layout.preferredWidth: 100 * AppFramework.displayScaleFactor
                        Layout.fillHeight: true
                        textFormat: Text.RichText
                        text: qsTr("Message") + "<span style:\"color:red\">*</span>"
                        verticalAlignment: Text.AlignTop
                        font.family: notoRegular
                    }
                    TextArea {
                        id: feedbackMessage
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        style: TextAreaStyle {
                            backgroundColor: Singletons.Config.formElementBackground
                            textColor: Singletons.Config.formElementFontColor
                            font.family: notoRegular
                            frame: Rectangle {
                                border.width: Singletons.Config.formElementBorderWidth
                                border.color: Singletons.Config.formElementBorderColor
                                anchors.fill: parent
                            }
                        }
                        onTextChanged: {
                             if(text.length > 0 && feedbackSubject.text.length > 0){
                                    sendFeedbackBtn.enabled = true;
                             }
                             else{
                                 sendFeedbackBtn.enabled = false;
                             }
                        }
                    }
                }
            }

            //--------------------------------------------------------------------------
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60 * AppFramework.displayScaleFactor

                RowLayout {
                    anchors.fill: parent
                    anchors.topMargin: 5 * AppFramework.displayScaleFactor
                    spacing: 0

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 150 * AppFramework.displayScaleFactor
                        Button {
                            id: cancelFeedbackBtn
                            anchors.fill: parent
                            anchors.margins: 10 * AppFramework.displayScaleFactor
                            anchors.leftMargin: 0
                            style: ButtonStyle {
                                background: Rectangle {
                                    anchors.fill: parent
                                    color: Singletons.Config.buttonStates(control, "major")
                                    radius: app.info.properties.mainButtonRadius
                                    border.width: app.info.properties.mainButtonBorderWidth
                                    border.color: app.info.properties.mainButtonBorderColor
                                }
                            }

                            Text {
                                color: app.info.properties.mainButtonBorderColor
                                anchors.centerIn: parent
                                textFormat: Text.RichText
                                text: qsTr("Cancel")
                                font.pointSize: Singletons.Config.baseFontSizePoint
                                font.family: notoRegular
                            }

                            onClicked: {
                                feedbackMessage.text = "";
                                feedbackSubject.text = "";
                                feedbackDialog.close();
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 150 * AppFramework.displayScaleFactor

                        Button {
                            id: sendFeedbackBtn
                            anchors.fill: parent
                            anchors.margins: 10 * AppFramework.displayScaleFactor
                            anchors.rightMargin: 0
                            enabled: false
                            style: ButtonStyle {
                                background: Rectangle {
                                    anchors.fill: parent
                                    color: Singletons.Config.buttonStates(control)
                                    radius: app.info.properties.mainButtonRadius
                                    border.width: control.enabled ? app.info.properties.mainButtonBorderWidth : 0
                                    border.color: app.info.properties.mainButtonBorderColor
                                }
                            }

                            Text {
                                color: app.info.properties.mainButtonFontColor
                                anchors.centerIn: parent
                                textFormat: Text.RichText
                                text: qsTr("Send")
                                font.pointSize: Singletons.Config.baseFontSizePoint
                                font.family: notoRegular
                            }


                            onClicked: {
                                try {
                                    var message = (feedbackMessage.text !== "") ? feedbackMessage.text : "No Message Entered."
                                    var subject = (feedbackSubject.text !== "") ? feedbackSubject.text : "No Subject Entered."
                                    feedbackDialog.metrics.sendFeedback(message, { "subject": subject });
                                    //metrics.sendFeedback(message, { "subject": subject });
                                } catch (e) {
                                    console.log(e)
                                } finally {
                                    feedbackMessage.text = "";
                                    feedbackSubject.text = "";
                                    feedbackDialog.close();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
