using System;

namespace GradeSystem.Models
{
    public class Grade
    {
        public int Id { get; set; }

        public DateTime Date { get; set; }

        public int Questionid { get; set; }

        public int Answer { get; set; }

        public int Week { get; set; }

        public string Team { get; set; }
    }
}