﻿using System.Collections.Generic;
using System.Linq;

namespace GradeSystem.Models
{
    public class Chart
    {
        public IEnumerable<string> Labels { get; set; }

        public IEnumerable<Dataset> Datasets { get; set; }

        public void Magi()
        {
            Labels = Labels.Reverse().Take(9).Reverse();
            Labels = new[] { "Avg last 10 weeks" }.Concat(Labels);

            var newDataSets = new List<Dataset>();

            foreach (var dataset in Datasets)
            {
                var avg = dataset
                    .Data
                    .Reverse()
                    .Skip(9)
                    .Take(10)
                    .Average();

                dataset.Data = new[] { avg }.Concat(dataset.Data.Reverse().Take(9).Reverse());
                newDataSets.Add(dataset);
            }

            Datasets = newDataSets;
        }
    }
}