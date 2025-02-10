import sys
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QObject, Signal, Slot, QTimer
from PySide6.QtGui import QIcon
from edupage_connect import EdupageAPI

class Backend(QObject):

    loginAttention = Signal()
    loginSuccess = Signal(bool)
    sendData = Signal(str)

    def __init__(self):
        super().__init__()

    @Slot(str, str, str)
    def login(self, school, username, password):

        self.loginAttention.emit()
        
        print(f"School: {school}, Username: {username}, Password: {password}")

        edupage = EdupageAPI()
        edupage.login(username, password, school)

        QTimer.singleShot(2000, self.check_login_status)

    def check_login_status(self):
        edupage = EdupageAPI()
        if edupage.isLoggedIn():
            print("Edupage logged in!")
            self.loginSuccess.emit(True)
            self.sendData.emit(str(edupage.getAverage()))
        else:
            print("Edupage login failed!")
            self.loginSuccess.emit(False)
            

if __name__ == "__main__":
    app = QApplication(sys.argv)
    app.setWindowIcon(QIcon("./WinApp/material/icon1.png"))
    engine = QQmlApplicationEngine()

    backend = Backend()

    # Backend in QML verfügbar machen
    engine.rootContext().setContextProperty("backend", backend)

    engine.load("./WinApp/qml/main.qml")  # Lade die UI

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec()) # Starte die Applikation