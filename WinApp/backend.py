from PySide6.QtCore import QObject, Signal, Slot, QTimer
from edupage_connect import EdupageAPI
from edupage_api import Term
import json

class Backend(QObject):

    loginAttention = Signal()
    loginSuccess = Signal(bool)
    sendData = Signal(str, str)

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
            QTimer.singleShot(400, lambda: self.sendDataToQML("chart", edupage.getMarkHistory(months=3, year=2024, term=Term.SECOND)))
        else:
            print("Edupage login failed!")
            self.loginSuccess.emit(False)

    @Slot()
    def getMarkStatistic(self):
        print("lol")

    def sendDataToQML(self, usage, data):
        self.sendData.emit(usage, data)