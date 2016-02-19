using System.Collections.Generic;

namespace GradeSystem.Models
{
    public class Chart
    {
        public IEnumerable<string> Labels { get; set; }

        public IEnumerable<Dataset> Datasets { get; set; }
    }
}