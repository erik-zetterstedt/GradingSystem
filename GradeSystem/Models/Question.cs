namespace GradeSystem.Models
{
    public class Question
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public int[] Grades { get; set; }
        public int PickedGrade { get; set; }
        public string Team { get; set; }

        public Question()
        {
            Grades = new[] { 1, 2, 3, 4, 5, 6, 7, 8 };
        }
    }
}