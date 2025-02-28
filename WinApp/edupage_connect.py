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

        now = datetime.now()
        start_date = now - relativedelta(months=months)

        grades_instance = Grades(self.edupage)
        # Alle Noten des aktuellen Halbjahres abrufen und auf den gewünschten Zeitraum filtern
        current_grades_all = grades_instance.get_grades(term=term, year=year)
        current_grades = [g for g in current_grades_all if start_date <= g.date <= now]

        # Prüfen, ob in den ersten 4 Wochen (28 Tage) des Zeitraums Noten existieren
        four_weeks_end = start_date + timedelta(days=28)
        initial_grades = [g for g in current_grades if start_date <= g.date < four_weeks_end]

        output = []

        # Falls in den ersten 4 Wochen keine Noten vorhanden sind, wird der "Fallback" aus dem vorherigen Term gesucht.
        if not initial_grades:
            # Bestimme den vorherigen Term gemäß der Vorgabe
            if term == Term.SECOND:
                fallback_term = Term.FIRST
                fallback_year = year
            elif term == Term.FIRST:
                fallback_term = Term.SECOND
                fallback_year = year - 1
            else:
                fallback_term = None

            fallback_grade_value = None
            if fallback_term is not None:
                fallback_grades_all = grades_instance.get_grades(term=fallback_term, year=fallback_year)
                if fallback_grades_all:
                    # Letzter Notenwert: der Eintrag mit dem spätesten Datum
                    fallback_grade = max(fallback_grades_all, key=lambda g: g.date)
                    fallback_grade_value = fallback_grade.grade_n

            # Bestimme den Start der ersten Woche, in der Noten im aktuellen Term vorliegen
            if current_grades:
                first_current_date = min(g.date for g in current_grades)
                # Wir runden auf den Wochenanfang (z. B. Montag)
                first_current_week = first_current_date - timedelta(days=first_current_date.weekday())
            else:
                first_current_week = now  # Falls es im aktuellen Term gar keine Noten gibt, füllen wir den gesamten Zeitraum

            # Fülle für jede Woche vom start_date bis zur ersten aktuellen Note einen Eintrag mit dem Fallback-Notenwert
            fallback_week_start = start_date
            while fallback_week_start < first_current_week:
                if fallback_grade_value is not None:
                    output.append({
                        "week": fallback_week_start.strftime("%Y-%m-%d"),
                        "average": fallback_grade_value
                    })
                fallback_week_start += timedelta(days=7)

        # Nun werden die Noten aus dem aktuellen Term verarbeitet.
        # Dabei gruppieren wir die Noten nach der Woche (z. B. beginnend mit Montag) und berechnen den Durchschnitt.
        week_grades = defaultdict(list)
        for g in current_grades:
            # Bestimme den Wochenanfang (Montag) der Note
            week_start = (g.date - timedelta(days=g.date.weekday())).date()
            week_grades[week_start].append(g.grade_n)

        # Für jede Woche, in der Noten vorliegen, wird ein Durchschnitt berechnet und in das Ergebnis aufgenommen.
        for week_start in sorted(week_grades.keys()):
            grades_in_week = week_grades[week_start]
            avg = sum(grades_in_week) / len(grades_in_week)
            output.append({
                "week": week_start.strftime("%Y-%m-%d"),
                "average": round(avg, 1)
            })

        # Ausgabe als JSON-String, der sich gut für ein QML-Liniendiagramm eignet
        return json.dumps(output)