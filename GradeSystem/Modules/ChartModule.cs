using System;
using System.Globalization;
using System.Linq;
using GradeSystem.Models;
using Nancy;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using PetaPoco;

namespace GradeSystem.Modules
{
    public class ChartModule : NancyModule
    {
        public ChartModule()
        {
            Get["/charts/{team}"] = parameters =>
            {
                string team = parameters.team;
                var chart = new Chart();

                using (var db = new Database("GradesDB"))
                {
                    var chartsData = db.Fetch<ChartsData>("select g.*, q.Title from grades g join Questions q on g.QuestionId = q.Id where Team = @0", team).ToList();

                    chart.Labels = chartsData
                        .GroupBy(c => new { c.Date.Year, c.Week })
                        .Select(c => string.Format("{0} v {1}", c.Key.Year, c.Key.Week));

                    chart.Datasets = chartsData
                        .GroupBy(x => new { x.Title, x.Questionid })
                        .Select(y => new Dataset()
                        {
                            Label = y.Key.Title,
                            QuestionId = y.Key.Questionid,
                            Data = y.GroupBy(x => new { x.Date.Year, x.Week }).Select(x => Math.Round(x.Average(z => z.Answer), 1)),
                            FillColor = "rgba(220,220,220,0)",
                            StrokeColor = GetColor(y.Key.Questionid),
                            PointColor = GetColor(y.Key.Questionid),
                            PointStrokeColor = "#fff",
                            PointHighlightFill = "#fff",
                            PointHighlightStroke = GetColor(y.Key.Questionid),

                        }).OrderBy(x => x.QuestionId);                 
                }

                return View["Views/charts.html",
                        new ChartViewModel
                        {
                            Team =   CultureInfo.CurrentCulture.TextInfo.ToTitleCase(team),
                            DataAsJson = JsonConvert.SerializeObject(chart, new JsonSerializerSettings { ContractResolver = new CamelCasePropertyNamesContractResolver() })
                        }];
            };
        }

        private static string GetColor(int id)
        {
            switch (id)
            {
                case 1:
                    return "rgba(144,195,212,1)";
                case 2:
                    return "rgba(195,144,212,1)";
                case 3:
                    return "rgba(161,212,144,1)";
                case 4:
                    return "rgba(212,161,144,1)";
                case 5:
                    return "rgba(234,252,66,1)";
                default:
                    return "rgba(220,220,220,1)";
            }
        }
    }
}