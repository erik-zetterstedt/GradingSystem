using System;
using System.Collections.Generic;
using System.Linq;

namespace GradeSystem.Models
{
    public class Chart
    {
        public IEnumerable<string> Labels { get; set; }

        public IEnumerable<Dataset> Datasets { get; set; }

        private bool avgExists;

        public void Magi()
        {
            Labels = Labels.Reverse().Take(9).Reverse();

            var newDataSets = new List<Dataset>();

            foreach (var dataset in Datasets)
            {
                if (dataset.Data.Count() > 9)
                {
                    AddAvgData(dataset);
                }

                newDataSets.Add(dataset);
            }

            Datasets = newDataSets;
        }

        private void AddAvgData(Dataset dataset)
        {
            var avg = dataset
                        .Data
                        .Reverse()
                        .Skip(9)
                        .Take(10)
                        .Average();

            dataset.Data = new[] { Math.Round(avg, 1) }.Concat(dataset.Data.Reverse().Take(9).Reverse());
            AddAvgLabel();
        }

        private void AddAvgLabel()
        {
            if (!avgExists)
            {
                Labels = new[] { "Avg last 10 weeks" }.Concat(Labels);
                avgExists = true;
            }
        }
    }
}