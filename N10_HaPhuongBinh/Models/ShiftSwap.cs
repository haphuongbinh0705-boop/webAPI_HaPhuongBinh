using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace N10_HaPhuongBinh.Models
{
    public class ShiftSwap
    {
        [Key]
        public int Id { get; set; }

        // Người xin đổi ca
        [Required]
        public int RequesterId { get; set; }
        [ForeignKey("RequesterId")]
        public User? Requester { get; set; }

        // Người được nhờ đổi ca
        [Required]
        public int TargetUserId { get; set; }
        [ForeignKey("TargetUserId")]
        public User? TargetUser { get; set; }

        public int CurrentShiftId { get; set; }
        [ForeignKey("CurrentShiftId")]
        public Shift? CurrentShift { get; set; }

        public int DesiredShiftId { get; set; }
        [ForeignKey("DesiredShiftId")]
        public Shift? DesiredShift { get; set; }

        public DateTime SwapDate { get; set; }

        [Required]
        [StringLength(100)]
        public string SwapQrCode { get; set; } = Guid.NewGuid().ToString("N");

        // "ChoXacNhan", "DaXacNhan", "TuChoi"
        [StringLength(30)]
        public string Status { get; set; } = "ChoXacNhan";

        public string? Note { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
