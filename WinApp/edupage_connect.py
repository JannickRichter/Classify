from edupage_api import Edupage
from edupage_api.exceptions import BadCredentialsException, CaptchaException
import math
import re
import json
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta
from collections import defaultdict
from edupage_api import Grades, Term
from variables import Variables

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

    def getAbiGrade(self, sub1, sub2, sub3, sub4, sub5=None, semi_mark=None):
        if not self.loggedIn: # Ist Benutzer eingelogt?
            print("Not logged in Edupage!")
            return None
        

        #Berechnung Block 1
        final_grades = defaultdict(dict)  # Speichert alle Noten für jedes Fach

        variables = Variables()

        klasse = variables.schoolClass
        school_year_edupage = variables.schoolYear

        if klasse == 11:
            start_year = school_year_edupage
        elif klasse == 12:
            start_year = school_year_edupage - 1

        #start_year = current_school_year - 1  # 11. Klasse beginnt ein Jahr vor der aktuellen Eingabe
        #end_year = current_school_year  # 12. Klasse endet im aktuellen Schuljahr

        for year in range(start_year, start_year + 2):  # Durchläuft 11. und 12. Klasse
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

                if total_grades < 3 * total_subjects:
                    print(f"Nicht genügend Noten für {year} {term} vorhanden.")
                    continue  # Halbjahr wird übersprungen

                # Berechnung der Noten
                for subject, subject_notes in subject_grades.items():
                    normal_grades = []
                    exam_grades = []

                    # Fächer nach Kursarbeiten filtern
                    for note in subject_notes:
                        if re.search(r"\b(ka|KA|kursarbeit|Kursarbeit|Klausur|klausur)\b", note.title) and subject.isupper():  
                            exam_grades.append(note.grade_n)  # Kursarbeiten speichern
                        else:
                            normal_grades.append(note.grade_n)  # Normale Noten speichern

                    # Gewichtung Kursarbeiten nur für Leistungskurse (Fächerkürzel in Großbuchstaben)
                    if exam_grades:  # Falls Fach großgeschrieben ist und Kursarbeiten existieren
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
            # Alle vorhandenen Noten sammeln
            all_grades = list(term_dict.values())  # Hier sind die Halbjahresnoten als Liste
            print(all_grades)
            # Fehlende Noten durch den Durchschnitt ersetzen
            while len(all_grades) < 4:
                if all_grades:  # Falls schon Noten vorhanden sind, berechne den Durchschnitt
                    avg = sum(all_grades) / len(all_grades)
                    all_grades.append(round(avg))  # Durchschnitt aufrunden und hinzufügen
                else:
                    return None # Falls keine Noten vorhanden sind

            # Neue Noten zurück in das Dictionary einfügen, basierend auf den Schuljahren und Halbjahren
            available_terms = sorted(term_dict.keys(), key=lambda x: (x[0], x[1].value))
            missing_terms = [(year, term) for year in range(start_year, start_year + 2) for term in [Term.FIRST, Term.SECOND] if (year, term) not in term_dict]

            for missing_term in missing_terms:
                if len(all_grades) == 0:
                    break
                term_dict[missing_term] = all_grades.pop(0)  # Fehlende Halbjahre mit Durchschnitt auffüllen

            # Endgültiges Dictionary speichern
            final_grades[subject] = dict(sorted(term_dict.items(), key=lambda x: (x[0][0], x[0][1].value)))
        # Dictionary, das speichert, wie viele Noten pro Fach bereits gestrichen wurden
        removed_count_per_subject = defaultdict(int)

        # Alle Halbjahre durchgehen
        for year in range(start_year, start_year + 2):
            for term in [Term.FIRST, Term.SECOND]:

                term_grades = {}  # Speichert Noten der Grundkurse in diesem Halbjahr
                    
                # Alle Fächer durchgehen
                for subject, grades in final_grades.items():
                    if subject.islower() and (year, term) in grades:  # Nur Grundkurse & vorhandene Noten
                        if removed_count_per_subject[subject] < 2:  # Maximal 2 Streichungen pro Fach
                            term_grades[subject] = grades[(year, term)]  # Speichern der Note

                # Falls Noten in diesem Halbjahr gefunden wurden, schlechteste Note entfernen
                if term_grades:
                    worst_subject = min(term_grades, key=term_grades.get)  # Fach mit der schlechtesten Note
                    worst_grade = term_grades[worst_subject]

                    # Note aus final_grades entfernen
                    del final_grades[worst_subject][(year, term)]
                    removed_count_per_subject[worst_subject] += 1  # Zähler für dieses Fach erhöhen
                    
                    print(f"Entfernt: Note {worst_grade} aus {worst_subject} ({year}, {term})")

        # Summe der Halbjahresergebnisse pro Fach 
        total_points_per_subject = {subject: sum(grades.values()) for subject, grades in final_grades.items()}

        weighted_points = 0  # Punkte mit Gewichtung
        faecher = []
        print("\nGesamtpunktzahl pro Fach:")
        for subject, points in total_points_per_subject.items():
            if subject.isupper():
                weighted_points += points * 2  # Leistungskurse doppelt gewichten

            if subject.islower():
                weighted_points += points # Grundkurse einfach gewichten
            faecher.append(subject)
            print(f"{subject}: {points} Punkte")

        block1 = 40 * weighted_points / 56 # Gewichtung der nun vorhanden 56 Halbjahresergebnisse auf 40 Halkbjahresergebnisse herunterbrechen

        # Gesamtpunktzahl in allen Fächern
        #block1 = sum(total_points_per_subject.values())

        # Namen aus der UI müssen in die Edupage Namen umgewandelt werden
        noten = self.getEduPageName(faecher, sub1, sub2, sub3, sub4, sub5)

        # Berechnung des Block2
        exam1 = noten[0]
        exam2 = noten[1]
        exam3 = noten[2]
        exam4 = noten[3]
        exam5 = noten[4]

        semi_mark = semi_mark

        exam = [exam1, exam2, exam3, exam4] # Prüfungen die jeder hat
        block2 = 0.0

        if exam5 == None: # Wenn Seminarfach existiert
            block2 = semi_mark * 4 # 4-fache Gewichtung

        if semi_mark == None: # Wenn Seminarfach nicht mit einfließt
            pruefung_grade = {} # DIctionary für die "Prüfungsnoten" 
            pruefung_grade = final_grades.get(exam5, {}) # Alle Halbhjaresnoten addieren -- Durchschnitt und vierfache Gewichtung kürzen sich
            block2 = block2 + sum(pruefung_grade.values())

        for i in exam: # Schleife für alle 4 Pflichtprüfungen -- Aufbau ist der selbe wie oben
            pruefung_grade = {} # leeres Dictionary
            pruefung_grade = final_grades.get(i, {}) # Alle halbjahresnoten des jeweiligen Faches zum Dictionary hinzufügen
            block2 = block2 + sum(pruefung_grade.values()) # Summe der Halbjahresergebnisse
            final_grades[i]
            print("Fächer des Fachs:" + str(i))
            print('Note nach: ' + str(i) + ' ' + str(block2))

        abitur_punkte = round(block1 + block2, 0) # Summe der Punkte aus Block1 und Block2
        print("Abiturpunkte" + str(abitur_punkte))

        # Berechnung des Notenschnitts
        abitur_note = 4.0 # Mindestduchschnitt
        x = 0 # Mindestpunktzahl für das Abitur
        noten_grenze = 300 + 17 * x + x

        if abitur_punkte <= 822: 
            while noten_grenze <= abitur_punkte:
                # Die Schleife wird solange durchlaufen bis die Notengrrenze gleich oder kleiner als die Abipunkte sind
                # Der Durchschnitt erhöht sich immer um 0,1, wenn sich die Notengrenze um 17 + x erhöht
                if noten_grenze == abitur_punkte:
                    abitur_note += 0.1
                x += 1
                noten_grenze = 300 + 17 * x + x
                abitur_note -= 0.1

        else: # ab einer Punktzahl von 823 hat man einen Durchschnitt von 1.0
            noten_counter = 1.0

        abitur_note = round(abitur_note, 1)
    
        print("Notenschnitt: " + str(abitur_note))

        return str(abitur_note) + "/" + str(int(round(abitur_punkte, 0)))
    

    def getEduPageName(self, faecher, sub1, sub2, sub3, sub4, sub5 = None):
        # Funktion um Namen aus der UI in die Edupage Namen umzuwandeln
        subjects = [sub1, sub2, sub3, sub4, sub5] # Liste der UI Fächer
        edupage_subjects = [] # Liste der Edupage Fächer
        
        # Naturwissenschaften
        if 'Mathe' in subjects: # Wenn Fach (Mathe) in der Liste der UI-Fächer ist
            if 'MA' in faecher: # Ist Fach (Mathe) Leistungskurs
                edupage_subjects.append('MA') # Fach (Mathe) wird in die Liste der Edupage Fächer als Leistungskurs hinzugefügt
            elif 'ma' in faecher: # Ist Fach (Mathe) Grundkurs
                edupage_subjects.append('ma')  # Fach (Mathe) wird in die Liste der Edupage Fächer als Grundkurs hinzugefügt

        # Dies wird nun für alle Fächer durchgeführt
        if 'Physik' in subjects:
            if 'PH' in faecher:
                edupage_subjects.append('PH')
            elif 'ph' in faecher:
                edupage_subjects.append('ph')

        if 'Chemie' in subjects:
            if 'CH' in faecher:
                edupage_subjects.append('CH')
            elif 'ch' in faecher:
                edupage_subjects.append('ch')

        if 'Biologie' in subjects:
            if 'BI' in faecher:
                edupage_subjects.append('BI')
            elif 'bi' in faecher:
                edupage_subjects.append('bi')

        if 'Astronomie' in subjects:
            if 'AS' in faecher:
                edupage_subjects.append('AS')
            elif 'as' in faecher:
                edupage_subjects.append('as')

        if 'Informatik' in subjects:
            if 'IF' in faecher:
                edupage_subjects.append('IF')
            elif 'if' in faecher:
                edupage_subjects.append('if')

        # Sprachen
        if 'Deutsch' in subjects:
            if 'DE' in faecher:
                edupage_subjects.append('DE')
            elif 'de' in faecher:
                edupage_subjects.append('de')

        if 'Englisch' in subjects:
            if 'EN' in faecher:
                edupage_subjects.append('EN')
            elif 'en' in faecher:
                edupage_subjects.append('en') 

        if 'Französisch' in subjects:
            if 'FR' in faecher:
                edupage_subjects.append('FR')
            elif 'fr' in faecher:
                edupage_subjects.append('fr')

        if 'Russisch' in subjects:
            if 'RU' in faecher:
                edupage_subjects.append('RU')
            elif 'ru' in faecher:
                edupage_subjects.append('ru')

        if 'Latein' in subjects:
            if 'LA' in faecher:
                edupage_subjects.append('LA')
            elif 'la' in faecher:
                edupage_subjects.append('la')

        if 'Italienisch' in subjects:
            if 'IT' in faecher:
                edupage_subjects.append('IT')
            elif 'it' in faecher:
                edupage_subjects.append('it')
        
        # Gesellschaftswissenschaften
        if 'Geschichte' in subjects:
            if 'GE' in faecher:
                edupage_subjects.append('GE')
            elif 'ge' in faecher:
                edupage_subjects.append('ge')

        if 'Wirtschaft' in subjects:
            if 'WR' in faecher:
                edupage_subjects.append('WR')
            elif 'wr' in faecher:
                edupage_subjects.append('wr')

        if 'Geografie' in subjects:
            if 'GG' in faecher:
                edupage_subjects.append('GG')
            elif 'gg' in faecher:
                edupage_subjects.append('gg') 

        if 'Sozialkunde' in subjects:
            if 'SK' in faecher:
                edupage_subjects.append('SK')
            elif 'sk' in faecher:
                edupage_subjects.append('sk')

        if 'Religion' in subjects:
            if 'RE' in faecher:
                edupage_subjects.append('RE')
            elif 're' in faecher:
                edupage_subjects.append('re')

        if 'Ethik' in subjects:
            if 'ET' in faecher:
                edupage_subjects.append('ET')
            elif 'et' in faecher:
                edupage_subjects.append('et')

        if 'Kunst' in subjects:
            if 'KU' in faecher:
                edupage_subjects.append('KU')
            elif 'ku' in faecher:
                edupage_subjects.append('ku')

        if 'Musik' in subjects:
            if 'MU' in faecher:
                edupage_subjects.append('MU')
            elif 'mu' in faecher:
                edupage_subjects.append('mu')
        
        sub1 = edupage_subjects[0]
        sub2 = edupage_subjects[1]
        sub3 = edupage_subjects[2]
        sub4 = edupage_subjects[3]

        if sub5 is not None:
            sub5 = edupage_subjects[4]
        else:
            sub5 = None

        return [sub1, sub2, sub3, sub4, sub5]
           

    # Durchschnitt in Abhängigkeit von Jahr und Halbjahr berechnen
    def getAverage(self, year: int, term: Term):
        if not self.loggedIn:
            print("Not logged in Edupage!")
            return None

        grades_instance = Grades(self.edupage)
        grades = grades_instance.get_grades(term=term, year=year)

        subject_grades = defaultdict(list)

        # Sammle alle Noten pro Fach
        for grade in grades:
            subject_grades[grade.subject_name].append(grade)

        total_sum = 0  # Summe der Fach-Durchschnitte
        total_count = 0  # Anzahl der Fächer

        for subject, subject_notes in subject_grades.items():
            normal_grades = []
            exam_grades = []

            for note in subject_notes:
                # Versuche, den Wert als float zu interpretieren
                # Falls dies scheitert, setze eine alternative Zahl (z.B. 0 oder ignore)
                try:
                    value = float(note.grade_n)
                except (ValueError, TypeError):
                    # Wenn das Notenfeld leer oder kein Float ist,
                    # kannst du es wahlweise ignorieren oder als 0.0 setzen
                    value = 0.0

                # Test auf Kursarbeit / Klausur
                if re.search(r"\b(ka|KA|Ka|kursarbeit|Kursarbeit|Klausur|klausur)\b", note.title) and subject.isupper():
                    exam_grades.append(value)
                else:
                    normal_grades.append(value)

            variables = Variables()

            # Durchschnitt berechnen
            if exam_grades and variables.schoolClass >= 11:  # Falls es Kursarbeiten gibt
                exam_weight = 1 / 3
                normal_weight = 2 / 3

                exam_avg = sum(exam_grades) / len(exam_grades) if len(exam_grades) > 0 else 0
                normal_avg = sum(normal_grades) / len(normal_grades) if len(normal_grades) > 0 else 0

                subject_avg = (exam_avg * exam_weight) + (normal_avg * normal_weight)
                subject_avg = round(subject_avg, 0)
            else:
                # Falls keine Kursarbeit existiert
                if len(normal_grades) > 0:
                    subject_avg = round(sum(normal_grades) / len(normal_grades), 0)
                else:
                    subject_avg = 0

            total_sum += subject_avg
            total_count += 1

        # Gesamtdurchschnitt über alle Fächer
        if total_count > 0:
            return round(total_sum / total_count, 2)
        else:
            return None

    
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