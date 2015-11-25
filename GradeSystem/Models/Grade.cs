using System.Security.Principal;

namespace GradeSystem.Models
{
    public class Grade
    {
        public int Id { get; set; }
        public string QuestionOne { get; set; }
        public int AnswerOne { get; set; }
        public string QuestionTwo { get; set; }
        public int AnswerTwo { get; set; }
        public string QuestionThree { get; set; }
        public int AnswerThree { get; set; }
        public string QuestionFour { get; set; }
        public int AnswerFour { get; set; }
        public string QuestionFive { get; set; }
        public int AnswerFive { get; set; }
    }
}