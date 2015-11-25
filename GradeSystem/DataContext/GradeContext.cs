using System.Data.Entity;
using GradeSystem.Models;

namespace GradeSystem.DataContext
{
    public class GradeContext : DbContext
    {
        public GradeContext() : base("name=GradesDB")
        {
        }
        public virtual DbSet<Grade> Grades { get; set; } 
    }
}