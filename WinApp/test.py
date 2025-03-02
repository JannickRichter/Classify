from edupage_connect import EdupageAPI
from edupage_api import Grades
from edupage_api import Term
from edupage_api import Subjects

edupage = EdupageAPI()

print(edupage.isLoggedIn())
print(edupage.getAverage(2024, Term.FIRST))