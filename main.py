import os, sys
from PySide6.QtGui import QGuiApplication, QPixmap
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle
from scripts.side_bar_manager import SideBarManager
from scripts.notes_manager import NotesManager

BASE = getattr(sys, "_MEIPASS", os.path.dirname(os.path.abspath(__file__)))

QQuickStyle.setStyle("Basic")
app = QGuiApplication(sys.argv)
app.setApplicationName("ProtonNotes")
engine = QQmlApplicationEngine()
app.setWindowIcon(QPixmap(os.path.join(BASE, "assets", "app-icon.png")))

notes_manager: NotesManager = NotesManager()

side_bar_manager = SideBarManager(app, notes_manager)
engine.rootContext().setContextProperty("sideBarManager", side_bar_manager)

engine.load(os.path.join(BASE, "ui", "Main.qml"))
sys.exit(app.exec())
