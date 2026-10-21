using System.ComponentModel.DataAnnotations;

namespace N10_HaPhuongBinh.Models
{
    public class Shift
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [StringLength(100)]
        public string ShiftName { get; set; } = string.Empty; // Ca sáng, Ca chiều, Ca tối

        [Required]
        public TimeSpan StartTime { get; set; } // 08:00:00

        [Required]
        public TimeSpan EndTime { get; set; } // 17:00:00

        public double SalaryRate { get; set; } = 1.0; // Hệ số lương (1.0 = chuẩn, 1.5 = ca tối/OT)

        public string? Description { get; set; }
    }
}
