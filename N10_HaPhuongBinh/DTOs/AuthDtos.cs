using System.ComponentModel.DataAnnotations;

namespace N10_HaPhuongBinh.DTOs
{
    public class RegisterDto
    {
        [Required]
        public string Username { get; set; } = string.Empty;

        [Required]
        [MinLength(3)]
        public string Password { get; set; } = string.Empty;

        [Required]
        public string FullName { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        public string? PhoneNumber { get; set; }

        public string Role { get; set; } = "NhanVien"; // Admin, NhanVien, QuanLy, Khach

        public string? Department { get; set; }
    }

    public class LoginDto
    {
        [Required]
        public string Username { get; set; } = string.Empty;

        [Required]
        public string Password { get; set; } = string.Empty;
    }

    public class VerifyOtpDto
    {
        [Required]
        public string Username { get; set; } = string.Empty;

        [Required]
        public string OtpCode { get; set; } = string.Empty;
    }

    public class FaceLoginDto
    {
        [Required]
        public string Username { get; set; } = string.Empty;

        [Required]
        public string FaceImageBase64 { get; set; } = string.Empty;
    }

    public class BiometricLoginDto
    {
        [Required]
        public string Username { get; set; } = string.Empty;

        [Required]
        public string BiometricToken { get; set; } = string.Empty;
    }
}
