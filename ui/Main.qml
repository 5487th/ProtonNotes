import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

ApplicationWindow {
    id: win
    visible: true
    title: "Proton Notes"
    width: 800; height: 600
    minimumWidth: 800; minimumHeight: 600

    flags: Qt.Window    
    
    property int selectedNoteId: -1
    property string selectedNoteName: ""


    readonly property bool dialogOpen: newNoteDialog.visible
                                   || renameDialog.visible
                                   || deleteDialog.visible


    SplitView{
        anchors.fill: parent
        orientation: Qt.Horizontal

        enabled: !win.dialogOpen

        layer.enabled: win.dialogOpen
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 1.0
            blurMax: 32
        }

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
                        
                        //qmllint disable unqualified
                        onTextEdited: sideBarManager.on_search(text)
                        //qmllint enable unqualified

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
                        
                        onClicked: newNoteDialog.open()
                    }
                }
                
                ListView{
                    Layout.fillHeight:true
                    Layout.fillWidth:true
                    Layout.leftMargin:10
                    Layout.rightMargin:10
                    Layout.topMargin:20
                    clip:true

                    //qmllint disable unqualified
                    model:sideBarManager.get_notes
                    //qmllint enable unqualified

                    spacing:5

                    delegate: FileCard{
                        required property int noteID
                        required property string noteName

                        note_id:noteID
                        note_name:noteName
                        width:ListView.view.width

                        //qmllint disable unqualified 
                        onRenameRequested: (id) => renameDialog.open(id, noteName)
                        //qmllint enable unqualified 

                        //qmllint disable unqualified 
                        onDeleteRequested: (id) => deleteDialog.open(id, noteName)
                        //qmllint enable unqualified 

                        //qmllint disable unqualified 
                        onClicked: (id, name) => {
                            win.selectedNoteId=id
                            win.selectedNoteName = name
                        }
                        //qmllint enable unqualified 

                    }
                }
            }
        }
        
    
        //main view
        Rectangle{
            SplitView.minimumWidth:450
            color: '#F8F9FC'
            
            ColumnLayout{
                anchors.fill: parent

                Rectangle{
                    Layout.fillWidth:true
                    Layout.preferredHeight: 50 
                    color:"#F0F2F8"
                    Rectangle{
                        color:"#DCE1EB"
                        height:3
                        width:parent.width
                        anchors.bottom:parent.bottom
                    }

                    Text{
                        id: noteTittleDisplay
                        text: win.selectedNoteId == -1 ? "Open a note" : win.selectedNoteName
                        anchors.left:parent.left
                        anchors.verticalCenter:parent.verticalCenter

                        anchors.leftMargin:10
                        font.pixelSize:16
                        font.family: "Inter"
                    }
                }
                ScrollView{
                    Layout.fillHeight:true
                    Layout.fillWidth:true
                    Layout.verticalStretchFactor:35
                    clip:true

                    TextArea{
                        id:noteEditor
                        wrapMode: TextEdit.Wrap
                        
                        color:"#000000"

                        placeholderText: "type something...."
                        font.pixelSize:16

                        //qmllint disable unqualified 
                        text:win.selectedNoteId == -1 ? "" : sideBarManager.get_note_content(win.selectedNoteId) 
                        onTextChanged: {
                            if(win.selectedNoteId !== -1){
                                sideBarManager.set_note_content(win.selectedNoteId, text)
                            }
                        }
                        //qmllint enable unqualified
                    }
                }
               
            }
        }
       
    }
    
   
    //new note dialogue
    Rectangle{
        id: newNoteDialog
        width:300
        height:200
        color:"#F8F9FC"
        radius:10
        border.color:"#DCE1EB"

        enabled:false
        visible:false

        anchors.centerIn:parent

        function submit(){
            if (noteNameField.text.trim().length===0){
                return
            }
            else{
                //qmllint disable unqualified
                sideBarManager.create_note(noteNameField.text.trim())
                //qmllint enable unqualified

                close()
            }
        }

        function close(){
            newNoteDialog.enabled=false
            newNoteDialog.visible=false
            noteNameField.clear()
        }

        function open(){
            newNoteDialog.enabled=true
            newNoteDialog.visible=true
            noteNameField.clear()

        }

        ColumnLayout{
            anchors.fill:parent
            anchors.margins:20
            spacing:12
            Label{
                text:"New note"
                font.pixelSize: 18
                font.family: "Inter"
                color:"#000000"
            }

            Label{
                text:"Give your note a name"
                font.pixelSize:13
                font.family: "Inter"
                color:"#73819D"
            }

            TextField{
                id: noteNameField
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                focus:true

                placeholderText:"Note name..."
                placeholderTextColor:"#73819D"
                verticalAlignment: TextInput.AlignVCenter
                color:"#243653"
                font.pixelSize:15
                font.family:"Inter"
                leftPadding: 12

                background: Rectangle{
                    color:"#F8F9FC"
                    border.color: noteNameField.activeFocus ? "#bdc2ca" : "#DCE1EB"
                    radius:10
                }
                onAccepted: newNoteDialog.submit()
            }

            Item {Layout.fillHeight:true}

            RowLayout{
                Layout.fillWidth:true
                spacing:10

                Item{Layout.fillWidth:true}

                //cancel button
                Button{
                    id: cancelBtn
                    text:"Cancel"
                    Layout.preferredWidth:90
                    Layout.preferredHeight:35
                    hoverEnabled:true
                    scale: pressed ? 0.95 : 1.0

                    contentItem:Text{
                        text:cancelBtn.text
                        font.pixelSize:14
                        font.family:"Inter"
                        color:"#243653"
                        horizontalAlignment:Text.AlignHCenter
                        verticalAlignment:Text.AlignVCenter
                    }
                    
                    background:Rectangle{
                        color: cancelBtn.hovered ? "#F0F2F8" : "#F8F9FC"
                        border.color:"#DCE1EB"
                        radius:10
                    }
                    HoverHandler { cursorShape: Qt.PointingHandCursor }

                    onClicked: newNoteDialog.close()
                }

                //create
                Button {
                    id: createBtn
                    text: "Create"
                    enabled: noteNameField.text.trim().length > 0
                    Layout.preferredWidth: 90
                    Layout.preferredHeight: 35
                    hoverEnabled: true
                    scale: pressed ? 0.95 : 1.0

                    contentItem: Text {
                        text: createBtn.text
                        font.pixelSize: 14
                        font.family: "Inter"
                        color: "#FFFFFF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: !createBtn.enabled ? "#A9B3C6"
                               : createBtn.hovered ? "#1a2a45" : "#243653"
                        radius: 10
                    }
                    HoverHandler { cursorShape: Qt.PointingHandCursor }

                    onClicked: newNoteDialog.submit()
                }
            }
        }
    }

    //rename note dialogue
    Rectangle{
        id: renameDialog
        width:300
        height:200
        color:"#F8F9FC"
        radius:10
        border.color:"#DCE1EB"

        enabled:false
        visible:false

        anchors.centerIn:parent
        property int noteId:-1

        function submit(){
            let name = renameField.text.trim()
            if (name.length === 0)
                return

            //qmllint disable unqualified
            sideBarManager.rename_note(noteId, name)
            //qmllint enable unqualified

            close()
        }

        function close(){
            renameDialog.enabled=false
            renameDialog.visible=false
            renameField.clear()
        }

        function open(id, currentName){
            noteId = id
            renameDialog.enabled=true
            renameDialog.visible=true
            renameField.text = currentName
            renameField.forceActiveFocus()
            renameField.selectAll()
        }

        ColumnLayout{
            anchors.fill:parent
            anchors.margins:20
            spacing:12
            
            Label{
                text:"Rename note"
                font.pixelSize:18
                font.family:"Inter"
                color:"#000000"
            }

            Label{
                text:"Enter a new name"
                font.pixelSize:13
                font.family: "Inter"
                color:"#73819D"
            }

            TextField{
                id: renameField
                Layout.fillWidth: true
                Layout.preferredHeight: 38

                placeholderText:"Note name..."
                placeholderTextColor:"#73819D"
                verticalAlignment: TextInput.AlignVCenter
                color:"#243653"
                font.pixelSize:15
                font.family:"Inter"
                leftPadding: 12

                background: Rectangle{
                    color:"#F8F9FC"
                    border.color: renameField.activeFocus ? "#bdc2ca" : "#DCE1EB"
                    radius:10
                }
                onAccepted: renameDialog.submit()
                Keys.onEscapePressed: renameDialog.close()

            }

            Item {Layout.fillHeight:true}
            
            RowLayout{
                Layout.fillWidth:true
                spacing:10

                Item{Layout.fillWidth:true}

                Button{
                        id: renameCancelBtn
                        text:"Cancel"
                        Layout.preferredWidth:90
                        Layout.preferredHeight:35

                        hoverEnabled:true
                        scale: pressed? 0.95 : 1.0

                        contentItem:Text{
                            text:renameCancelBtn.text
                            font.pixelSize:14
                            font.family:"Inter"
                            color:"#243653"
                            horizontalAlignment:Text.AlignHCenter
                            verticalAlignment:Text.AlignVCenter
                        }

                        background:Rectangle{
                            color: renameCancelBtn.hovered ? "#F0F2F8" : "#F8F9FC"
                            border.color:"#DCE1EB"
                            radius:10
                        }

                        HoverHandler { cursorShape: Qt.PointingHandCursor }

                        onClicked: renameDialog.close()
                }

                Button {
                    id: renameConfirmBtn
                    text: "Rename"
                    enabled: renameField.text.trim().length > 0
                    Layout.preferredWidth: 90
                    Layout.preferredHeight: 35
                    hoverEnabled: true
                    scale: pressed ? 0.95 : 1.0
                    contentItem: Text {
                        text: renameConfirmBtn.text
                        font.pixelSize: 14
                        font.family: "Inter"
                        color: "#FFFFFF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: !renameConfirmBtn.enabled ? "#A9B3C6"
                               : renameConfirmBtn.hovered ? "#1a2a45" : "#243653"
                        radius: 10
                    }
                    HoverHandler {
                        enabled: renameConfirmBtn.enabled
                        cursorShape: Qt.PointingHandCursor
                    }
                    onClicked: renameDialog.submit()
                }

            }
        }
    }

    //delete note dialogue 
    Rectangle{
        id: deleteDialog
        width:300
        height:200
        color:"#F8F9FC"
        radius:10
        border.color:"#DCE1EB"
        
        enabled:false
        visible: false

        anchors.centerIn:parent
        property int noteId:-1
        property string noteName:""

        function submit(){
            //qmllint disable unqualified
            sideBarManager.delete_note(noteId)
            //qmllint enable unqualified

            close()
        }

        function close(){
            deleteDialog.enabled=false
            deleteDialog.visible=false
        }

        function open(id, name){
            noteId = id
            noteName = name
            deleteDialog.enabled=true
            deleteDialog.visible=true
            deleteDialog.forceActiveFocus()
        }

        Keys.onEscapePressed: close()
        Keys.onReturnPressed: submit()
        
        ColumnLayout{
            anchors.fill:parent
            anchors.margins:20
            spacing:12

            Label{
                text:"Delete note"
                font.pixelSize:18
                font.family:"Inter"
                color:"#000000"
            }

            Label{
                Layout.fillWidth: true
                text:'Are you sure you want to delete "' + deleteDialog.noteName + '"? This can\'t be undone.'
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                maximumLineCount: 3
                font.pixelSize:13
                font.family:"Inter"
                color:"#73819D"
            }

            Item {Layout.fillHeight:true}

            RowLayout{
                Layout.fillWidth:true
                spacing:10

                Item {Layout.fillWidth:true}

                Button{
                    id: deleteCancelBtn
                    text:"Cancel"
                    Layout.preferredWidth:90
                    Layout.preferredHeight:35
                    hoverEnabled:true
                    scale:pressed ? 0.95 : 1.0

                    contentItem:Text{
                        text:deleteCancelBtn.text
                        font.pixelSize:14
                        font.family:"Inter"
                        color:"#243653"
                        horizontalAlignment:Text.AlignHCenter
                        verticalAlignment:Text.AlignVCenter
                    }

                    background:Rectangle{
                        color: deleteCancelBtn.hovered ? "#F0F2F8" : "#F8F9FC"
                        border.color:"#DCE1EB"
                        radius:10
                    }

                    HoverHandler{cursorShape:Qt.PointingHandCursor}

                    onClicked: deleteDialog.close()
                }

                Button{
                    id: deleteConfirmBtn
                    text:"Delete"
                    Layout.preferredWidth:90
                    Layout.preferredHeight:35
                    hoverEnabled:true
                    scale: pressed ? 0.95 : 1.0

                    contentItem:Text{
                        text:deleteConfirmBtn.text   // was deleteCancelBtn.text
                        font.pixelSize:14
                        font.family:"Inter"
                        color:"#FFFFFF"
                        horizontalAlignment:Text.AlignHCenter
                        verticalAlignment:Text.AlignVCenter
                    }

                    background: Rectangle{
                        color: deleteConfirmBtn.hovered ? "#A93226" : "#C0392B"
                        radius:10
                    }

                    HoverHandler{cursorShape:Qt.PointingHandCursor}

                    onClicked: deleteDialog.submit()
                }
            }
        }
    }
    
}
