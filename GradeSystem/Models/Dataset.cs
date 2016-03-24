using System.Collections.Generic;

namespace GradeSystem.Models
{
    public class Dataset
    {
        public string Label { get; set; }

        public int QuestionId { get; set; }

        public string FillColor { get; set; }

        public string StrokeColor { get; set; }

        public string PointColor { get; set; }

        public string PointStrokeColor { get; set; }

        public string PointHighlightFill { get; set; }

        public string PointHighlightStroke { get; set; }

        public IEnumerable<double> Data { get; set; }

        public IEnumerable<int> NumberOfAnswers { get; set; }
    }
}