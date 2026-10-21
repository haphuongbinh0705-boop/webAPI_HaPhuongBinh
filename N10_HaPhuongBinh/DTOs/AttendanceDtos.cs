using System.ComponentModel.DataAnnotations;

namespace N10_HaPhuongBinh.DTOs
{
    public class CheckInDto
    {
        [Required]
        public int UserId { get; set; }

        public int? ShiftId { get; set; }

        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
        public string? LocationAddress { get; set; }

        public string Method { get; set; } = "GPS"; // "QR", "FACE", "FINGERPRINT", "GPS"

        public string? CheckInPhoto { get; set; }

        public string? QrCode { get; set; }

        public string? Note { get; set; }
    }

    public class CheckOutDto
    {
        [Required]
        public int UserId { get; set; }

        public double? Latitude { get; set; }
        public double? Longitude { get; set; }

        public string? Note { get; set; }
    }

    public class CreateLeaveRequestDto
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        public string LeaveType { get; set; } = "Nghỉ phép năm";

        [Required]
        public DateTime FromDate { get; set; }

        [Required]
        public DateTime ToDate { get; set; }

        [Required]
        public string Reason { get; set; } = string.Empty;
    }

    public class UpdateLeaveStatusDto
    {
        [Required]
        public string Status { get; set; } = "DaDuyet"; // "DaDuyet", "TuChoi"

        public string? AdminComment { get; set; }
    }

    public class CreateShiftSwapDto
    {
        [Required]
        public int RequesterId { get; set; }

        [Required]
        public int TargetUserId { get; set; }

        [Required]
        public int CurrentShiftId { get; set; }

        [Required]
        public int DesiredShiftId { get; set; }

        [Required]
        public DateTime SwapDate { get; set; }

        public string? Note { get; set; }
    }

    public class ConfirmShiftSwapDto
    {
        [Required]
        public string SwapQrCode { get; set; } = string.Empty;

        [Required]
        public int TargetUserId { get; set; }
    }
}
