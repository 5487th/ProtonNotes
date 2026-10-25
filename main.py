import os, sys
from ctypes import wintypes
import ctypes

from PySide6.QtGui import QGuiApplication, QPixmap
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle
from PySide6.QtCore import QAbstractNativeEventFilter

from scripts.side_bar_manager import SideBarManager
from scripts.notes_manager import NotesManager

BASE = getattr(sys, "_MEIPASS", os.path.dirname(os.path.abspath(__file__)))

user32 = ctypes.windll.user32
user32.IsZoomed.argtypes = [wintypes.HWND]
user32.IsZoomed.restype = wintypes.BOOL
user32.GetSystemMetrics.argtypes = [ctypes.c_int]
user32.GetSystemMetrics.restype = ctypes.c_int
user32.GetWindowRect.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.RECT)]
user32.GetWindowRect.restype = wintypes.BOOL

dwmapi = ctypes.windll.dwmapi

user32.SetWindowPos.argtypes = [
    wintypes.HWND,
    wintypes.HWND,
    ctypes.c_int,
    ctypes.c_int,
    ctypes.c_int,
    ctypes.c_int,
    wintypes.UINT,
]
user32.SetWindowPos.restype = wintypes.BOOL

dwmapi.DwmSetWindowAttribute.argtypes = [
    wintypes.HWND,
    wintypes.DWORD,
    ctypes.c_void_p,
    wintypes.DWORD,
]
dwmapi.DwmSetWindowAttribute.restype = ctypes.c_long


class NCCALCSIZE_PARAMS(ctypes.Structure):
    _fields_ = [
        ("rgrc", wintypes.RECT * 3),
        ("lppos", ctypes.c_void_p),
    ]


WM_NCCALCSIZE = 0x0083
WM_NCHITTEST = 0x0084

HTLEFT, HTRIGHT, HTTOP, HTTOPLEFT, HTTOPRIGHT = 10, 11, 12, 13, 14
HTBOTTOM, HTBOTTOMLEFT, HTBOTTOMRIGHT = 15, 16, 17


class NativeFilter(QAbstractNativeEventFilter):
    def __init__(self, hwnd):
        super().__init__()
        self.hwnd = hwnd

    def nativeEventFilter(self, eventType, message):
        if bytes(eventType) != b"windows_generic_MSG":
            return False, 0

        msg = wintypes.MSG.from_address(int(message))

        if msg.hWnd != self.hwnd:
            return False, 0

        if msg.message == WM_NCCALCSIZE and msg.wParam:
            if user32.IsZoomed(self.hwnd):
                params = ctypes.cast(
                    msg.lParam, ctypes.POINTER(NCCALCSIZE_PARAMS)
                ).contents
                rect = params.rgrc[0]
                pad = user32.GetSystemMetrics(92)
                fx = user32.GetSystemMetrics(32) + pad
                fy = user32.GetSystemMetrics(33) + pad
                rect.left += fx
                rect.right -= fx
                rect.top += fy
                rect.bottom -= fy
            return True, 0

        if msg.message == WM_NCHITTEST and not user32.IsZoomed(self.hwnd):
            x = ctypes.c_short(msg.lParam & 0xFFFF).value
            y = ctypes.c_short((msg.lParam >> 16) & 0xFFFF).value

            rect = wintypes.RECT()
            user32.GetWindowRect(self.hwnd, ctypes.byref(rect))

            border = user32.GetSystemMetrics(32) + user32.GetSystemMetrics(92)

            left = x - rect.left < border
            right = rect.right - x < border
            top = y - rect.top < border
            bottom = rect.bottom - y < border

            hit = 0
            if top and left:
                hit = HTTOPLEFT
            elif top and right:
                hit = HTTOPRIGHT
            elif bottom and left:
                hit = HTBOTTOMLEFT
            elif bottom and right:
                hit = HTBOTTOMRIGHT
            elif left:
                hit = HTLEFT
            elif right:
                hit = HTRIGHT
            elif top:
                hit = HTTOP
            elif bottom:
                hit = HTBOTTOM

            if hit:
                return True, hit

        return False, 0


QQuickStyle.setStyle("Basic")

app = QGuiApplication(sys.argv)
app.setApplicationName("ProtonNotes")
app.setWindowIcon(QPixmap(os.path.join(BASE, "assets", "app-icon.png")))


engine = QQmlApplicationEngine()

notes_manager: NotesManager = NotesManager()

side_bar_manager = SideBarManager(app, notes_manager)
engine.rootContext().setContextProperty("sideBarManager", side_bar_manager)

engine.load(os.path.join(BASE, "ui", "Main.qml"))

root = engine.rootObjects()[0]
hwnd = int(root.winId())

native_filter = NativeFilter(hwnd)
app.installNativeEventFilter(native_filter)

user32.SetWindowPos(hwnd, None, 0, 0, 0, 0, 0x0001 | 0x0002 | 0x0004 | 0x0010 | 0x0020)

corner_pref = ctypes.c_int(2)
dwmapi.DwmSetWindowAttribute(
    hwnd, 33, ctypes.byref(corner_pref), ctypes.sizeof(corner_pref)
)

sys.exit(app.exec())
