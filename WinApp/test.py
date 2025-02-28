from edupage_connect import EdupageAPI
from edupage_api import Grades
from edupage_api import Term
from edupage_api import Subjects

edupage = EdupageAPI()
edupage.login("jannickrichter@web.de", "JRNinjago2007!?", "duden-gymn")

print(edupage.isLoggedIn())
print(edupage.getMarkHistory(5, 2024, Term.SECOND))


"""subjects = Subjects(edupage.edupage)
grades = []
grades_instance = Grades(edupage.edupage)  # Erstelle eine Instanz von Grades
for grade in grades_instance.get_grades(term=Term.FIRST, year=2023):
    if grade.subject_name == "MA":
        grades.append(grade)
print(grades)
print(subjects.get_subjects())
print(grades_instance.get_grades(term=Term.SECOND, year=2023))"""