from edupage_api import Edupage
from edupage_api.exceptions import BadCredentialsException, CaptchaException
from edupage_api import Grades
from edupage_api import Term
import re
import json
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta
from collections import defaultdict
from edupage_api import Grades, Term

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

    def getAverage(self):
        if not self.loggedIn:
            print("Not logged in Edupage!")
            return None

        grades_instance = Grades(self.edupage)
        grades = grades_instance.get_grades(term=Term.FIRST, year=2024)

        subject_grades = defaultdict(list)

        for grade in grades:
            subject_grades[grade.subject_name].append(grade)

        print(subject_grades)

        total_sum = 0  # Gesamtsumme aller Fach-Durchschnitte
        total_count = 0  # Anzahl der Fächer für den Durchschnitt

        # Alle Fächer durchgehen
        for subject, subject_notes in subject_grades.items():
            normal_grades = []
            exam_grades = []

            # Fächer nach Kursarbeiten filtern
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
    
    def getMarkHistory(self, months: int, year: int, term: Term):
        if not self.loggedIn:
            print("Not logged in Edupage!")
            return None

        # Aktuelles Datum und Startdatum berechnen
        now = datetime.now()
        start_date = now - relativedelta(months=months)

        # Alle Noten für das angegebene Halbjahr abrufen
        grades_instance = Grades(self.edupage)
        grades = grades_instance.get_grades(term=term, year=year)

        # Nur Noten berücksichtigen, die im Zeitraum zwischen start_date und now liegen
        relevant_grades = [g for g in grades if start_date <= g.date <= now]

        # Wochenweise die Notendurchschnitte berechnen
        week_data = []
        current_week_start = start_date
        last_week_average = None

        # Solange bis zum aktuellen Datum iterieren
        while current_week_start < now:
            # Bestimme das Ende der aktuellen Woche (7 Tage später)
            current_week_end = current_week_start + timedelta(days=7)
            if current_week_end > now:
                current_week_end = now

            # Finde alle Noten, die in die aktuelle Woche fallen
            week_grades = [g.grade_n for g in relevant_grades if current_week_start <= g.date < current_week_end]

            # Berechne den Wochendurchschnitt oder übernehme den letzten Wert, wenn keine Note vorliegt
            if week_grades:
                week_average = sum(week_grades) / len(week_grades)
            else:
                week_average = last_week_average if last_week_average is not None else 0

            last_week_average = week_average

            # Füge die Ergebnisse (z.B. mit Datum als Start der Woche) der Liste hinzu
            week_data.append({
                "week": current_week_start.strftime("%Y-%m-%d"),
                "average": round(week_average, 1)
            })

            # Zur nächsten Woche wechseln
            current_week_start = current_week_end

        # Rückgabe als JSON-String, geeignet für ein QML-Liniendiagramm
        return json.dumps(week_data)