using System.Collections.Generic;
using System.Data.Entity.Migrations;
using System.Linq;
using GradeSystem.DataContext;
using GradeSystem.Models;
using Nancy;

namespace GradeSystem.Modules
{
    public class StartModule : NancyModule
    {
        public StartModule()
        {
            Get["/"] = _ => View["Start.cshtml", GetKeyValuePairs()];

            Get["/{id}"] = _ =>
            {
                ViewBag.currentId = _.id;
                var currentUser = GetCurrentUser(_.id);
                ViewBag.Contains = GetKeyValuePairs().Contains(new KeyValuePair<int, string>(currentUser.Key, currentUser.Value));

                return View["Start.cshtml", GetKeyValuePairs()];
            };

            Post["/{id}"] = _ =>
            {
                var currentUser = GetCurrentUser(_.id);
                SaveGrade(currentUser.Value);
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
                new KeyValuePair<int, string>(5, "Christoffer"),
                new KeyValuePair<int, string>(6, "Torbjörn"),
                new KeyValuePair<int, string>(7, "Hans-Göran")
            }.OrderBy(x=>x.Value).ToList();
        } 

        public void SaveGrade(string username)
        {
            using (var context = new GradeContext())
            {
                context.Grades.Add(new Grade    
                {
                    Name = username,
                    QuestionOne = "Hur roligt har du haft det?",
                    QuestionTwo = "Hur nöjd är du med egen insats/prestation?",
                    QuestionThree = "Hur nöjd är du med teamets samarbete och förmåga att arbeta tillsammans?",
                    QuestionFour = "Hur bra förutsättningar har teamet haft?",
                    QuestionFive = "Hur hög arbetsro rådde under perioden (avsaknad av störningar)?",
                    AnswerOne = (int)Request.Form["First"],
                    AnswerTwo =  (int)Request.Form["Second"],
                    AnswerThree = (int)Request.Form["Third"],
                    AnswerFour = (int)Request.Form["Fourth"],
                    AnswerFive =(int)Request.Form["Fifth"]
                });
                context.SaveChanges();
            }
        }
        public KeyValuePair<int, string> GetCurrentUser(int id)
        {
            return GetKeyValuePairs().FirstOrDefault(x => x.Key == id);
        }
    }
}