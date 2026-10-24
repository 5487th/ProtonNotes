import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle{
    id:root
    property string note_name
    property int note_id

    signal renameRequested(int id)
    signal deleteRequested(int id)
    signal clicked(int id, string name)


    height:40
    color: '#F8F9FC'
    border.color: "#DCE1EB"
    radius:10
    
    TapHandler {
        onTapped: root.clicked(root.note_id, root.note_name)
    }

    HoverHandler { cursorShape: Qt.PointingHandCursor }

    component MenuEntry: MenuItem {
        id: entry
        property color textColor: "#243653"

        implicitWidth: 140
        implicitHeight: 32
        hoverEnabled: true

        contentItem: Text {
            text: entry.text
            font.pixelSize: 14
            font.family: "Inter"
            color: entry.textColor
            verticalAlignment: Text.AlignVCenter
            leftPadding: 8
        }

        background: Rectangle {
            color: entry.hovered ? "#F0F2F8" : "transparent"
            radius: 6
        }
    }

    RowLayout{
        anchors.fill:parent
    
        Image{
            source:"../assets/file.svg"
            Layout.preferredWidth:20
            Layout.preferredHeight:20

            Layout.leftMargin:10
            Layout.topMargin:2
            Layout.bottomMargin:2
            Layout.rightMargin:2
        }

        Text{
            Layout.fillWidth:true
            Layout.fillHeight:true
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight

            text : root.note_name

            font.pixelSize: 16
        }
        
        Rectangle{
            id:dotsBtn

            Layout.preferredWidth:30
            Layout.preferredHeight:30

            Layout.leftMargin:4
            Layout.topMargin:2
            Layout.bottomMargin:2
            Layout.rightMargin:5

            color: mouseArea.containsMouse || menu.opened ? "#F0F2F8" : '#00ffffff'
            radius:10



            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true 
                cursorShape: Qt.PointingHandCursor
                onClicked: menu.opened ? menu.close() : menu.open()
            }

            Image{
                source:"../assets/dots-vertical.svg"
                anchors.fill:parent
                anchors.margins:5
            }

            Menu{
                id: menu

                x:dotsBtn.width - width
                y:dotsBtn.height+4
                padding:4

                width: 148                 
                height: 2 * 32 + 2 * 4      

                background: Rectangle {
                    color: "#F8F9FC"
                    border.color: "#DCE1EB"
                    radius: 10
                }

                MenuEntry {
                    text: "Rename"
                    onTriggered: root.renameRequested(root.note_id)
                }
                MenuEntry {
                    text: "Delete"
                    textColor: "#C0392B"
                    onTriggered: root.deleteRequested(root.note_id)
                }
            }
        }
    }  
}
