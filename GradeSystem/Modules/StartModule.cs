using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using GradeSystem.Models;
using Nancy;
using Nancy.ModelBinding;
using PetaPoco;

namespace GradeSystem.Modules
{
    public class StartModule : NancyModule
    {
        public StartModule()
        {
            Get["/"] = _ => View["Content/index.html"];

            Get["/questions"] = _ =>
            {
                using (var db = new Database("GradesDB"))
                {
                    return Response.AsJson(db.Fetch<Question>("select * from questions").ToList());
                }
            };

            Post["/submission"] = _ =>
            {
                var questions = this.Bind<Question[]>();
                var date = DateTime.Now;

                using (var db = new Database("GradesDB"))
                {
                    foreach (var question in questions)
                    {
                        db.Save("Grades", "Id", new Grade
                        {
                            Questionid = question.Id,
                            Answer =  question.PickedGrade,
                            Date = date,
                            Week = GetWeek(date)
                        });
                    }
                }

                return Response.AsJson("Saved", HttpStatusCode.Created);
            };
        }

        private static int GetWeek(DateTime date)
        {
            var day = (int)CultureInfo.CurrentCulture.Calendar.GetDayOfWeek(date);
            return CultureInfo.CurrentCulture.Calendar.GetWeekOfYear(date.AddDays(4 - (day == 0 ? 7 : day)), CalendarWeekRule.FirstFourDayWeek, DayOfWeek.Monday);
        }
    }
}