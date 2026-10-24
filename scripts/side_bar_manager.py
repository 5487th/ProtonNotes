from PySide6.QtCore import Slot, QObject, Signal, Property

from scripts.notes_manager import NotesManager


class SideBarManager(QObject):
    update_notes: Signal = Signal()

    def __init__(self, parent, notes_manager: NotesManager):

        super().__init__(parent)

        self.notes_manager: NotesManager = notes_manager
        self._notes = []
        self._filter = ""

        self.refresh_side_bar()

    def refresh_side_bar(self):
        self._notes = []
        for note in self.notes_manager.get_all_notes():
            self._notes.append({"noteID": note.id, "noteName": note.name})

        self.update_notes.emit()

    @Property("QVariantList", notify=update_notes)
    def get_notes(self):
        if self._filter == "":
            return self._notes

        query = self._filter.casefold()
        matches = []
        for n in self._notes:
            if query in n["noteName"].casefold():
                matches.append(n)
        return matches

    @Slot(str)
    def on_search(self, text):
        self._filter = text.strip()
        self.refresh_side_bar()

    @Slot(str)
    def create_note(self, text):
        self.notes_manager.add_note(text)
        self.refresh_side_bar()

    @Slot(int, str)
    def rename_note(self, id, text):
        self.notes_manager.rename_note(id, text)
        self.refresh_side_bar()

    @Slot(int)
    def delete_note(self, id):
        self.notes_manager.delete_note(id)
        self.refresh_side_bar()

    @Slot(int, result=str)
    def get_note_content(self, id):
        return self.notes_manager.get_content(id)

    @Slot(int, str)
    def set_note_content(self, id, content):
        self.notes_manager.update_content(id, content)
