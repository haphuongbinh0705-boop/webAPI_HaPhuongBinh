using System.ComponentModel.DataAnnotations;

namespace N10_HaPhuongBinh.Models
{
    public class User
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [StringLength(50)]
        public string Username { get; set; } = string.Empty;

        [Required]
        public string Password { get; set; } = string.Empty;

        [Required]
        [StringLength(100)]
        public string FullName { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        [StringLength(100)]
        public string Email { get; set; } = string.Empty;

        [StringLength(20)]
        public string? PhoneNumber { get; set; }

        /// <summary>
        /// Vai trò: "Admin", "NhanVien", "QuanLy", "Khach"
        /// </summary>
        [Required]
        [StringLength(20)]
        public string Role { get; set; } = "NhanVien";

        [StringLength(100)]
        public string? Department { get; set; }

        public string? AvatarUrl { get; set; }

        // Dữ liệu nhận diện khuôn mặt (ảnh mẫu hoặc embedding base64)
        public string? FaceData { get; set; }

        // Mã sinh trắc học vân tay
        public string? BiometricToken { get; set; }

        // Mã OTP xác thực khi đăng nhập
        public string? OtpCode { get; set; }
        public DateTime? OtpExpiry { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
