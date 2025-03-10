from edupage_api import Edupage
from edupage_api.exceptions import BadCredentialsException, CaptchaException
from edupage_api import Grades
from edupage_api import Term
import math
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
    def getAbiGrade(self, current_school_year: int, current_term: int):
        if not self.loggedIn: # Ist Benutzer eingelogt?
            print("Not logged in Edupage!")
            return None
        
        final_grades = defaultdict(dict)  # Speichert alle Noten für jedes Fach

        # BERARBEITEN MIT JANNICK
        # Hier muss nochmal eine Bearbeitung stattfinden. 
        start_year = current_school_year - 1  # 11. Klasse beginnt ein Jahr vor der aktuellen Eingabe
        end_year = current_school_year  # 12. Klasse endet im aktuellen Schuljahr

        for year in range(start_year, end_year + 1):  # Durchläuft 11. und 12. Klasse
            for term in [Term.FIRST, Term.SECOND]:  # Beide Halbjahre berücksichtigen
                grades_instance = Grades(self.edupage)
                grades = grades_instance.get_grades(term=term, year=year)

                subject_grades = defaultdict(list)

                # Noten nach Fächern gruppieren
                for grade in grades:
                    subject_grades[grade.subject_name].append(grade)

                # Bedingung: Sind genügend Noten für das Halbjahr vorhanden?
                total_grades = sum(len(notes) for notes in subject_grades.values())  # Gesamtanzahl der Noten
                total_subjects = len(subject_grades)  # Anzahl der Fächer

                if total_grades < 2 * total_subjects:
                    print(f"Nicht genügend Noten für {year} {term} vorhanden.")
                    continue  # Halbjahr wird übersprungen

                # Berechnung der Noten
                for subject, subject_notes in subject_grades.items():
                    normal_grades = []
                    exam_grades = []

                    # Fächer nach Kursarbeiten filtern
                    for note in subject_notes:
                        if re.search(r"\b(ka|KA|kursarbeit|Kursarbeit|Klausur|klausur)\b", note.title):  
                            exam_grades.append(note.grade_n)  # Kursarbeiten speichern
                        else:
                            normal_grades.append(note.grade_n)  # Normale Noten speichern

                    # Gewichtung Kursarbeiten nur für Leistungskurse (Fächerkürzel in Großbuchstaben)
                    if subject.isupper() and exam_grades:  # Falls Fach großgeschrieben ist und Kursarbeiten existieren
                        exam_weight = 1 / 3
                        normal_weight = 2 / 3
                    else:  # Falls es ein Grundkurs ist oder keine Kursarbeiten existieren
                        exam_weight = 0
                        normal_weight = 1

                    # Durchschnitt berechnen
                    exam_avg = sum(exam_grades) / len(exam_grades) if exam_grades else 0
                    normal_avg = sum(normal_grades) / len(normal_grades) if normal_grades else 0

                    subject_avg = (exam_avg * exam_weight) + (normal_avg * normal_weight)

                    # Note auf ganze Zahl runden (ab ,5 aufrunden)
                    rounded_avg = math.ceil(subject_avg) if subject_avg % 1 >= 0.5 else round(subject_avg)

                    # Speicherung aller Noten für das Fach (mit Edupage-Namen)
                    final_grades[subject][(year, term)] = rounded_avg  # Speichert die Note mit Jahr und Halbjahr

        # Sicherstellen, dass jedes Fach genau 4 Halbjahresnoten hat
        for subject, term_dict in final_grades.items():
            all_grades = list(term_dict.values())  # Werte direkt in eine Liste umwandeln

            while len(all_grades) < 4:
                avg = sum(all_grades) / len(all_grades)  # Durchschnitt der vorhandenen Noten berechnen
                all_grades.append(round(avg))  # Fehlende Noten mit dem gerundeten Durchschnitt ersetzen

            # Noten wieder pro Halbjahr aufteilen
            final_grades[subject] = dict(zip(sorted(term_dict.keys(), key=lambda x: (x[0], x[1].value)), all_grades))

        # Noten streichen für Grundkurse (kleines Fächerkürzel)
        to_remove = 4  # 4 Noten dürfen gestrichen werden
        removed_per_term = defaultdict(int)  # Speichert, wie viele Noten pro Halbjahr entfernt wurden

        # Liste der Grundkurse filtern (kleines Fächerkürzel)
        grundkurse = {subject: grades for subject, grades in final_grades.items() if subject.islower()}

        # Schlechte Noten in Grundkursen streichen
        for subject, term_grades in sorted(grundkurse.items(), key=lambda x: min(x[1].values()), reverse=True):
            if to_remove <= 0:
                break # wenn bereits 4 Noten gestrichen wurden

            sorted_terms = sorted(term_grades.items(), key=lambda x: x[1])  # Sortieren nach schlechtester Note

            removed_count = 0  # Zähler für dieses Fach
            for term_year, grade in sorted_terms:
                if removed_count < 2 and to_remove > 0 and removed_per_term[term_year] == 0:
                    del final_grades[subject][term_year]  # Note entfernen
                    removed_per_term[term_year] += 1  # Halbjahr als gestrichen markieren
                    removed_count += 1
                    to_remove -= 1

                if to_remove <= 0:
                    break

        return final_grades
    


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
    

# Objekt der EdupageAPI-Klasse erstellen
edupage_instance = EdupageAPI()

# Mit Benutzerdaten anmelden (ersetze durch echte Daten)
username = "ErikThrum"
password = "1Hans!!!"
school = "duden-gymn"
edupage_instance.login(username, password, school)

# Falls erfolgreich eingeloggt, getAbiGrade ausführen
if edupage_instance.isLoggedIn():
    current_school_year = 2024  # Beispiel: aktuelles Schuljahr
    current_term = Term.FIRST  # Beispiel: 1. Halbjahr

    # Notenberechnung starten
    result = edupage_instance.getAbiGrade(current_school_year, current_term)

    print(result)
else:
    print("Login fehlgeschlagen! Überprüfe Benutzername, Passwort und Schule.")

