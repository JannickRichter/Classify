from edupage_api import Term

class Variables():
    _instance = None

    # Globale Variablen (von außen erreichbar OOP)
    schoolClass = 12
    schoolHalf = Term.SECOND
    schoolYear = 2024
    lastMonths = 3

    def __init__(self):
        super().__init__()

    def setLastMonths(self, months):
        self.lastMonths = months

    def setSchoolClass(self, value: int):
        self.schoolClass = value

    def setSchoolHalf(self, term: Term):
        self.schoolHalf = term

    def setSchoolYear(self, year: int):
        self.schoolYear = year