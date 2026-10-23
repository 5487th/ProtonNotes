import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: win
    visible: true
    title: "Proton Notes"
    width: 800; height: 600
    minimumWidth: 800; minimumHeight: 600

    flags: Qt.Window    
   
    SplitView{
        anchors.fill: parent
        orientation: Qt.Horizontal

        handle: Rectangle {
                implicitWidth:3
                color: "#DCE1EB"
            }

        //side bar
        Rectangle{
            color: "#F0F2F8"
            SplitView.minimumWidth:230

            ColumnLayout
            {
                anchors.fill:parent
                

                //tittle
                Label{
                    text: "Proton Notes"
                    Layout.fillWidth: true
                    topPadding:15
                    leftPadding:15
                    
                    font.pixelSize : 18
                    font.family : "Inter"
                    color : "#000000"
                }

                //search and add note
                RowLayout{
                    Layout.fillWidth :true

                    Layout.topMargin:10
                    Layout.leftMargin:10
                    Layout.rightMargin:10
                    
                    // search bar
                    TextField {
                        id: searchbar
                        Layout.fillWidth :true

                        // Layout.topMargin:10
                        // Layout.leftMargin:10
                        // Layout.rightMargin:10

                        leftPadding:40

                        Layout.preferredHeight:35

                        placeholderText:"Search notes..."
                        placeholderTextColor:"#73819D"
                        verticalAlignment: TextInput.AlignVCenter

                        color: "#243653"
                        font.pixelSize:15


                        background: Rectangle{
                            color: "#F8F9FC"
                            border.color: searchbar.activeFocus ? '#bdc2ca' : "#DCE1EB"
                            radius: 10
                        }

                        //search icon
                        Image{
                            source: "../assets/search.svg"
                            width: 20
                            height: 20
                            fillMode: Image.PreserveAspectCrop
                            anchors.left:parent.left
                            anchors.verticalCenter:searchbar.verticalCenter
                            anchors.leftMargin:10
                        }
                    }

                    Button {
                        id: add
                        icon.source: "../assets/file-plus.svg"
                        icon.width:35
                        icon.height:35
                        icon.color: "transparent" 

                        Layout.preferredWidth:35
                        Layout.preferredHeight:35

                        background: Rectangle{
                            color: "#F8F9FC"
                            border.color:  "#DCE1EB"
                            radius: 10
                        }

                        transformOrigin: Item.Center

                        scale: pressed? 0.95 : 1.0 

                        hoverEnabled:true

                        HoverHandler{cursorShape: Qt.PointingHandCursor}
                        
                    }
                }
                
                ListView{
                    Layout.fillHeight:true
                    Layout.fillWidth:true

                    
                }
            }
        }
        

        //main view
        Rectangle{
            SplitView.minimumWidth:450
            color: '#F8F9FC'

        }
       
    }
}
