from PySide6.QtCore import QObject, Signal, Slot, QTimer
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

        edupage = EdupageAPI()
        edupage.login(username, password, school)

        QTimer.singleShot(1200, self.check_login_status)

    def check_login_status(self):
        edupage = EdupageAPI()
        if edupage.isLoggedIn():
            print("Edupage logged in!")
            self.loginSuccess.emit(True)
        else:
            print("Edupage login failed!")
            self.loginSuccess.emit(False)

    @Slot()
    def getMarkStatistic(self):
        print("lol")