import sys
from PySide6.QtGui import QGuiApplication, QPixmap
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle
from scripts.side_bar_manager import SideBarManager
from scripts.notes_manager import NotesManager

QQuickStyle.setStyle("Basic")
app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()
app.setWindowIcon(QPixmap("assets/app-icon.png"))

notes_manager: NotesManager = NotesManager()

side_bar_manager = SideBarManager(app, notes_manager)
engine.rootContext().setContextProperty("sideBarManager", side_bar_manager)

engine.load("ui/Main.qml")
sys.exit(app.exec())
