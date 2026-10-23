from peewee import Model, SqliteDatabase, AutoField, TextField
from pathlib import Path


class Note(Model):
    id = AutoField()
    name = TextField()
    content = TextField(null=True)


class NotesManager:
    def __init__(self):
        self.database_path = Path("data") / "notes.db"

        self.database_path.parent.mkdir(parents=True, exist_ok=True)

        self.db = SqliteDatabase(self.database_path)

        Note.bind(self.db)

        # create table if it doesnt exist
        self.db.create_tables([Note], safe=True)

    def add_note(self, name, initial_content=None):
        return Note.create(name=name, content=initial_content)

    def delete_note(self, id):
        try:
            note = Note.get(Note.id == id)
            note.delete_instance()
            return True
        except Note.DoesNotExist:
            return False

    def get_all_notes(self):
        return list(Note.select())

    def rename_note(self, id, name):
        try:
            note = Note.get(Note.id == id)
            note.name = name
            note.save()
            return True
        except Note.DoesNotExist:
            return False

    def update_content(self, id, new_content):
        try:
            note = Note.get(Note.id == id)
            note.content = new_content
            note.save()
        except Note.DoesNotExist:
            return False
