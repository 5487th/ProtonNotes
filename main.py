import sys
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle

QQuickStyle.setStyle("Basic")

app = QGuiApplication(sys.argv)

engine = QQmlApplicationEngine()

engine.load("Main.qml")

sys.exit(app.exec())
