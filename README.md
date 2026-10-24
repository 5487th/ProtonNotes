# Proton Notes

A lightweight desktop notes app built with Python, PySide6 and QML. Notes are stored locally in a SQLite database, and each note can be edited as plain text or viewed as rendered Markdown.

## Features

- Create, rename and delete notes
- Search notes by name from the sidebar
- Autosave: every edit is written to the database as you type
- Markdown preview mode (toggle with the eye button in the header)
- Clickable links in the preview (opened in your default browser)
- Currently selected note is highlighted in the sidebar
- Resizable sidebar with a minimum width
- Dialogs for new, rename and delete actions, with the background blurred while open

## Requirements

- Python 3.10 or newer
- [PySide6](https://pypi.org/project/PySide6/) (Qt 6)
- [peewee](https://pypi.org/project/peewee/)
- The [Inter](https://rsms.me/inter/) font installed (optional; Qt falls back to a default font if missing)

## Installation

```bash
git clone <your-repo-url>
cd <your-repo-folder>

python -m venv .venv
source .venv/bin/activate      # Windows: .venv\Scripts\activate

pip install PySide6 peewee
```

## Running

```bash
python main.py
```

On first launch the app creates its database automatically in your user data folder:

- Windows: `%APPDATA%\ProtonNotes\notes.db`
- Linux: `~/.local/share/ProtonNotes/notes.db`
- macOS: `~/Library/Application Support/ProtonNotes/notes.db`

## Project structure

```
.
├── main.py                     # App entry point, sets up the QML engine
├── assets/                     # Icons (search, file, eye, dots, app icon, ...)
├── scripts/
│   ├── notes_manager.py        # Database layer (peewee model + CRUD)
│   └── side_bar_manager.py     # QObject exposed to QML as `sideBarManager`
└── ui/
    ├── Main.qml                # Main window, editor, preview and dialogs
    └── FileCard.qml            # Sidebar note card component
```

## How it works

- `NotesManager` wraps a peewee `Note` model (`id`, `name`, `content`) and handles all database operations.
- `SideBarManager` sits between the database and the UI. It is registered in QML as the context property `sideBarManager` and exposes slots such as `create_note`, `rename_note`, `delete_note`, `get_note_content`, `set_note_content` and `on_search`, plus a `get_notes` property that the sidebar list binds to.
- In `Main.qml`, a `StackLayout` switches between the raw editor and a read-only preview. The preview is a `TextArea` with `textFormat: TextEdit.MarkdownText`, fed by the editor's text. A small helper preserves single line breaks and extra blank lines so the preview resembles what you typed.
- The editor always keeps the raw Markdown. Only the preview renders it, so saved notes are never altered by formatting.

## Usage

| Action | How |
| --- | --- |
| New note | Click the file-plus button next to the search bar |
| Open a note | Click it in the sidebar |
| Rename or delete | Click the three-dot menu on a note card |
| Search | Type in the search bar |
| Toggle Markdown preview | Click the eye icon in the header |

## Known limitations

- Qt's Markdown renderer has no syntax highlighting for code blocks and limited control over paragraph spacing.
- Each keystroke triggers a database write. This is fine for small notes but could be debounced for large ones.
