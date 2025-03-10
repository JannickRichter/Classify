from edupage_api import Edupage
from edupage_api.exceptions import BadCredentialsException, CaptchaException
import re
import json
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta
from collections import defaultdict
from edupage_api import Grades, Term

# EdupageAPI Klasse als Singleton (ein Element, immer wieder aufrufbar)
class EdupageAPI(Edupage):
    _instance = None  # Singleton-Instanz
    loggedIn = False

    def __new__(cls, *args, **kwargs):
        if cls._instance is None:
            cls._instance = super(EdupageAPI, cls).__new__(cls)
            cls._instance.edupage = Edupage()
            cls._instance.username = ""
            cls._instance.password = ""
            cls._instance.school = ""
        return cls._instance

    # Login Funktion
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

    # loggedIn Variable abfragen
    def isLoggedIn(self):
        return self.loggedIn

    # Abidurchschnitt berechnen
    def getAbiGrade(self):
        if not self.loggedIn:
            print("Not logged in Edupage!")
            return None

    # Durchschnitt in Abhängigkeit von Jahr und Halbjahr berechnen
    def getAverage(self, year: int, term: Term):
        if not self.loggedIn:
            print("Not logged in Edupage!")
            return None

        grades_instance = Grades(self.edupage)
        grades = grades_instance.get_grades(term=term, year=year)

        subject_grades = defaultdict(list)

        for grade in grades:
            subject_grades[grade.subject_name].append(grade)

        total_sum = 0  # Gesamtsumme der Fach-Durchschnitte
        total_count = 0  # Anzahl Fächer

        # Alle Fächer durchgehen
        for subject, subject_notes in subject_grades.items():
            normal_grades = []
            exam_grades = []

            # nach Kursarbeiten filtern
            for note in subject_notes:
                if re.search(r"\b(ka|KA|Ka|kursarbeit|Kursarbeit|Klausur|klausur)\b", note.title):  # Kursarbeit erkennen
                    exam_grades.append(note.grade_n)
                else:
                    normal_grades.append(note.grade_n)

            # Durchschnitt berechnen
            if exam_grades:  # Falls Kursarbeit existiert
                exam_weight = 1 / 3
                normal_weight = 2 / 3

                exam_avg = sum(exam_grades) / len(exam_grades) if exam_grades else 0
                normal_avg = sum(normal_grades) / len(normal_grades) if normal_grades else 0

                subject_avg = round((exam_avg * exam_weight) + (normal_avg * normal_weight), 0)
            else:  # Falls keine Kursarbeit existiert
                subject_avg = round(sum(normal_grades) / len(normal_grades), 0) if normal_grades else 0

            total_sum += subject_avg
            total_count += 1

        # Gesamtdurchschnitt berechnen
        return round(total_sum / total_count, 2) if total_count > 0 else None
    
    # Notenverlauf als JSON String (Verlauf) in Abhängigkeit von aktuellem Schuljahr, Halbjahr und den einzurechnenden Monaten
    def getMarkHistory(self, months: int, year: int, term: Term):
        if not self.loggedIn:
            print("Not logged in Edupage!")
            return None

        now = datetime.now()
        start_date = now - relativedelta(months=months)

        grades_instance = Grades(self.edupage)
        
        # Notendaten des aktuellen Schulhalbjahres abrufen
        current_grades = grades_instance.get_grades(term=term, year=year)
        
        # Bestimme die beiden vorherigen Schulhalbjahre (Fallback) abhängig vom aktuellen Term
        if term == Term.SECOND:
            fallback_term1, fallback_year1 = Term.FIRST, year
            fallback_term2, fallback_year2 = Term.SECOND, year - 1
        elif term == Term.FIRST:
            fallback_term1, fallback_year1 = Term.SECOND, year - 1
            fallback_term2, fallback_year2 = Term.FIRST, year - 1
        else:
            fallback_term1 = fallback_term2 = None

        fallback_grades1 = grades_instance.get_grades(term=fallback_term1, year=fallback_year1) if fallback_term1 is not None else []
        fallback_grades2 = grades_instance.get_grades(term=fallback_term2, year=fallback_year2) if fallback_term2 is not None else []
        
        # Noten aller Halbjahre addieren
        all_grades = current_grades + fallback_grades1 + fallback_grades2

        # Filtere Noten nach Datum (zwischen Startdatum und jetzt)
        filtered_grades = [g for g in all_grades if start_date <= g.date <= now]

        # Noten nach Kalenderwochen gruppieren
        week_grades = defaultdict(list)
        for g in filtered_grades:
            week_start = (g.date - timedelta(days=g.date.weekday())).date()
            week_grades[week_start].append(g.grade_n)

        output = []
        # Berechne pro Woche den Durchschnitt und füge nur Wochen mit Noten ein
        for week_start in sorted(week_grades.keys()):
            grades_in_week = week_grades[week_start]
            avg = sum(grades_in_week) / len(grades_in_week)
            output.append({
                "week": week_start.strftime("%Y-%m-%d"),
                "average": round(avg, 1)
            })

        # Ausgabe als JSON-String für QML Diagramm
        return json.dumps(output)
