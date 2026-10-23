from PySide6.QtCore import Slot, QObject


class SideBarManager(QObject):
    def __init__(self, parent, notes_manager):
        super().__init__(parent)

        self.notes_manager = notes_manager

    @Slot(str)
    def on_search(self, text):
        print(text)
