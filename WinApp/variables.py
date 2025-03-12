from edupage_api import Term

class Variables():
    _instance = None

    # Globale Variablen (von außen erreichbar OOP)
    schoolClass = 12
    schoolHalf = Term.SECOND
    schoolClassSelected = False
    schoolYear = 2024
    lastMonths = 3

    def __init__(self):
        super().__init__()

    def setClassSelected(self, state: bool):
        self.schoolClassSelected = state