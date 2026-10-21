using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace N10_HaPhuongBinh.Models
{
    public class AttendanceRecord
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int UserId { get; set; }

        [ForeignKey("UserId")]
        public User? User { get; set; }

        public int? ShiftId { get; set; }
        [ForeignKey("ShiftId")]
        public Shift? Shift { get; set; }

        public DateTime Date { get; set; } = DateTime.Today;

        public DateTime? CheckInTime { get; set; }
        public DateTime? CheckOutTime { get; set; }

        // Toạ độ GPS thực tế lúc check-in
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
        public string? LocationAddress { get; set; }
        public bool IsLocationValid { get; set; } = true; // Hợp lệ nếu nằm trong bán kính công ty

        // Phương thức chấm công: "QR", "FACE", "FINGERPRINT", "GPS"
        public string Method { get; set; } = "GPS";

        // Ảnh chụp khuôn mặt lúc chấm công (Base64 hoặc URL)
        public string? CheckInPhoto { get; set; }

        // Trạng thái: "DungGio", "DiMuon", "VeSom", "VangMat"
        [StringLength(30)]
        public string Status { get; set; } = "DungGio";

        public string? Note { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
