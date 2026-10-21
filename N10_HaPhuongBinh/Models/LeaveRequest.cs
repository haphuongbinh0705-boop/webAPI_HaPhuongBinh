using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace N10_HaPhuongBinh.Models
{
    public class LeaveRequest
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int UserId { get; set; }

        [ForeignKey("UserId")]
        public User? User { get; set; }

        [Required]
        [StringLength(50)]
        public string LeaveType { get; set; } = "Nghỉ phép năm"; // Nghỉ phép năm, Nghỉ ốm, Việc riêng, Thai sản

        [Required]
        public DateTime FromDate { get; set; }

        [Required]
        public DateTime ToDate { get; set; }

        [Required]
        public string Reason { get; set; } = string.Empty;

        // Trạng thái: "ChoDuyet", "DaDuyet", "TuChoi"
        [StringLength(30)]
        public string Status { get; set; } = "ChoDuyet";

        public string? AdminComment { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
