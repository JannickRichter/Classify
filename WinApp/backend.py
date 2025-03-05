from PySide6.QtCore import QObject, Signal, Slot, QTimer
from edupage_connect import EdupageAPI
from datetime import datetime
from edupage_api import Term, Grades

class Backend(QObject):

    loginAttention = Signal()
    loginSuccess = Signal(bool)
    sendData = Signal(str, str)

    schoolClass = 12
    schoolHalf = Term.SECOND
    schoolYear = 2024
    lastMonths = 3

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
        grade_instance = Grades(edupage.edupage)

        if len(grade_instance.get_grades(term=self.schoolHalf, year=datetime.now().year)) > 0:
            self.schoolYear = int(datetime.now().year)
        elif len(grade_instance.get_grades(term=self.schoolHalf, year=(int(datetime.now().year) - 1))) > 0:
            self.schoolYear = int(datetime.now().year) - 1
        
        if edupage.isLoggedIn():
            print("Edupage logged in!")
            self.loginSuccess.emit(True)
            QTimer.singleShot(400, lambda: self.sendDataToQML("chart", edupage.getMarkHistory(months=3, year=self.schoolYear, term=self.schoolHalf)))
            QTimer.singleShot(400, lambda: self.sendDataToQML("average", str(edupage.getAverage(self.schoolYear, self.schoolHalf))))
        else:
            print("Edupage login failed!")
            self.loginSuccess.emit(False)

    @Slot(int)
    def getMarkStatistic(self, months):
        edupage = EdupageAPI()
        if months == 0:
            self.sendDataToQML("chart", edupage.getMarkHistory(months=self.lastMonths, year=self.schoolYear, term=self.schoolHalf))
        else:
            self.lastMonths = months
            self.sendDataToQML("chart", edupage.getMarkHistory(months=months, year=self.schoolYear, term=self.schoolHalf))

    def sendDataToQML(self, usage, data):
        self.sendData.emit(usage, data)

    @Slot(str)
    def getAverage(self, selection):
        edupage = EdupageAPI()
        year = int(selection.split("/")[0])
        term = int(selection.split("/")[1])
        if term == 1:
            self.sendDataToQML("average", str(edupage.getAverage(year, Term.FIRST)))
        elif term == 2:
            self.sendDataToQML("average", str(edupage.getAverage(year, Term.SECOND)))

    @Slot(str)
    def noteClass(self, selection):
        self.schoolClass = int(selection.split("/")[0])
        self.schoolHalf = Term.FIRST if int(selection.split("/")[1]) == 1 else Term.SECOND

        if self.schoolClass == 12 or self.schoolClass == 11:
            self.sendDataToQML("chart_scale", "15")
        else:
            self.sendDataToQML("chart_scale", "6")