from edupage_api import Edupage
from edupage_api.exceptions import BadCredentialsException, CaptchaException
from edupage_api import Grades
from edupage_api import Term

class EdupageAPI(Edupage):
    _instance = None  # Singleton-Instanz
    loggedIn = False

    def __new__(cls, *args, **kwargs):
        # Erstelle nur eine Instanz der Klasse
        if cls._instance is None:
            cls._instance = super(EdupageAPI, cls).__new__(cls)
            cls._instance.edupage = Edupage()
            cls._instance.username = ""
            cls._instance.password = ""
            cls._instance.school = ""
        return cls._instance

    def login(self, username: str, password: str, school: str):
        self.username = username
        self.password = password
        self.school = school
        try:
            self.edupage.login(self.username, self.password, self.school)
        except BadCredentialsException:
            print("Wrong username or password!")
            return None
        except CaptchaException:
            print("Captcha required!")
            return None
        except Exception:
            print("Anderer Login Fehler!")
            return None
        self.loggedIn = True

    def logOut(self):
        self.loggedIn = False

    def isLoggedIn(self):
        return self.loggedIn

    def getAbiGrade(self):
        if not self.loggedIn:
            print("Not logged in Edupage!")
            return None
        
        grades = []
        grades_instance = Grades(self.edupage)  # Erstelle eine Instanz von Grades
        for grade in grades_instance.get_grades(term=Term.SECOND, year=2023):
            grades.append(f"{grade.subject_name}: {grade.grade_n}")

        return grades
    
    def getAverage(self):
        if not self.loggedIn:
            print("Not logged in Edupage!")
            return None
        
        sum = 0
        count = 0
        grades_instance = Grades(self.edupage)  # Erstelle eine Instanz von Grades
        for grade in grades_instance.get_grades(term=Term.FIRST, year=2024):
            sum += grade.grade_n
            count += 1

        return sum / count