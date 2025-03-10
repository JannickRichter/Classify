import sys
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtGui import QIcon
from backend import Backend

if __name__ == "__main__":
    app = QApplication(sys.argv)
    app.setWindowIcon(QIcon("./WinApp/material/icon1.png"))
    engine = QQmlApplicationEngine()

    backend = Backend()

    # Backend nach QML
    engine.rootContext().setContextProperty("backend", backend)

    engine.load("./WinApp/qml/main.qml")  # Lädt die UI

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())