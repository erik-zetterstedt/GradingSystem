using System.Collections.Generic;
using System.Linq;
using GradeSystem.Models;
using Nancy;
using PetaPoco;

namespace GradeSystem.Modules
{
    public class StartModule : NancyModule
    {
        public StartModule()
        {
            Get["/"] = _ => View["Content/index.html"];

            Get["/index2"] = _ => View["Content/index2.html"];

            Get["/questions"] = _ =>
            {
                using (var db = new Database("GradesDB"))
                {
                    return Response.AsJson(db.Fetch<Question>("select * from questions").ToList());
                }
            };

            Post["/submission"] = _ =>
            {
                using (var db = new Database("GradesDB"))
                {
                    db.Save("Grades", "Id", new Grade
                    {
                        QuestionOne = "Hur roligt har du haft det?",
                        QuestionTwo = "Hur nöjd är du med egen insats/prestation?",
                        QuestionThree = "Hur nöjd är du med teamets samarbete och förmåga att arbeta tillsammans?",
                        QuestionFour = "Hur bra förutsättningar har teamet haft?",
                        QuestionFive = "Hur hög arbetsro rådde under perioden (avsaknad av störningar)?",
                        AnswerOne = (int)Request.Form["First"],
                        AnswerTwo = 0,
                        AnswerThree = 0,
                        AnswerFour = 0,
                        AnswerFive = 0
                    });
                }
                return View["Start.cshtml", GetKeyValuePairs()];
            };
        }

        public List<KeyValuePair<int, string>> GetKeyValuePairs()
        {
            return new List<KeyValuePair<int, string>>
            {
                new KeyValuePair<int, string>(1, "Milad"),
                new KeyValuePair<int, string>(2, "William"),
                new KeyValuePair<int, string>(3, "Erik"),
                new KeyValuePair<int, string>(4, "Richard"),
                new KeyValuePair<int, string>(5, "Kristoffer"),
                new KeyValuePair<int, string>(6, "Torbjörn"),
                new KeyValuePair<int, string>(7, "Hans-Göran"),
                new KeyValuePair<int, string>(8, "Hugo")
            }.OrderBy(x=>x.Value).ToList();
        } 

        public KeyValuePair<int, string> GetCurrentUser(int id)
        {
            return GetKeyValuePairs().FirstOrDefault(x => x.Key == id);
        }
    }
}