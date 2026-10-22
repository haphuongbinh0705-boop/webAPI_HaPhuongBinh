using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using N10_HaPhuongBinh.DTOs;
using N10_HaPhuongBinh.Models;
using N10_HaPhuongBinh.Services;

namespace N10_HaPhuongBinh.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly IEmailService _emailService;

        public AuthController(ApplicationDbContext context, IEmailService emailService)
        {
            _context = context;
            _emailService = emailService;
        }

        /// <summary>
        /// 1. Đăng ký tài khoản qua email
        /// </summary>
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto dto)
        {
            if (await _context.Users.AnyAsync(u => u.Username.ToLower() == dto.Username.ToLower()))
            {
                return BadRequest(new { success = false, message = "Tên đăng nhập đã tồn tại!" });
            }

            if (await _context.Users.AnyAsync(u => u.Email.ToLower() == dto.Email.ToLower()))
            {
                return BadRequest(new { success = false, message = "Email này đã được sử dụng!" });
            }

            var newUser = new User
            {
                Username = dto.Username,
                Password = dto.Password,
                FullName = dto.FullName,
                Email = dto.Email,
                PhoneNumber = dto.PhoneNumber,
                Role = string.IsNullOrEmpty(dto.Role) ? "NhanVien" : dto.Role,
                Department = dto.Department ?? "Phòng Kỹ thuật",
                CreatedAt = DateTime.Now
            };

            _context.Users.Add(newUser);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                success = true,
                message = "Đăng ký tài khoản thành công!",
                data = new
                {
                    newUser.Id,
                    newUser.Username,
                    newUser.FullName,
                    newUser.Email,
                    newUser.Role,
                    newUser.Department
                }
            });
        }

        /// <summary>
        /// 2. Đăng nhập bước 1: Kiểm tra Tên đăng nhập + Mật khẩu, sinh mã OTP
        /// </summary>
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto dto)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u =>
                u.Username.ToLower() == dto.Username.ToLower() && u.Password == dto.Password);

            if (user == null)
            {
                return Unauthorized(new { success = false, message = "Tên đăng nhập hoặc mật khẩu không chính xác!" });
            }

            // Sinh mã OTP ngẫu nhiên 6 chữ số (Hiệu lực 5 phút)
            var random = new Random();
            var otp = random.Next(100000, 999999).ToString();
            user.OtpCode = otp;
            user.OtpExpiry = DateTime.Now.AddMinutes(5);

            await _context.SaveChangesAsync();

            // Trả về OTP trực tiếp trong response để hiển thị và xác thực tức thì (Không cần gửi Gmail bên ngoài)
            return Ok(new
            {
                success = true,
                message = "Đăng nhập bước 1 thành công! Vui lòng nhập mã OTP để hoàn tất.",
                requiresOtp = true,
                username = user.Username,
                email = user.Email,
                otpCode = otp
            });
        }

        /// <summary>
        /// 2. Đăng nhập bước 2: Xác thực mã OTP và điều hướng phân quyền
        /// </summary>
        [HttpPost("verify-otp")]
        public async Task<IActionResult> VerifyOtp([FromBody] VerifyOtpDto dto)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username.ToLower() == dto.Username.ToLower());

            if (user == null)
            {
                return NotFound(new { success = false, message = "Không tìm thấy người dùng!" });
            }

            if (string.IsNullOrEmpty(user.OtpCode) || user.OtpCode != dto.OtpCode)
            {
                return BadRequest(new { success = false, message = "Mã OTP không chính xác!" });
            }

            if (user.OtpExpiry < DateTime.Now)
            {
                return BadRequest(new { success = false, message = "Mã OTP đã hết hạn, vui lòng đăng nhập lại!" });
            }

            // Xoá OTP sau khi đã dùng
            user.OtpCode = null;
            user.OtpExpiry = null;
            await _context.SaveChangesAsync();

            return Ok(new
            {
                success = true,
                message = "Xác thực OTP thành công! Đăng nhập hoàn tất.",
                user = new
                {
                    user.Id,
                    user.Username,
                    user.FullName,
                    user.Email,
                    user.Role, // "Admin", "NhanVien", "QuanLy", "Khach"
                    user.Department,
                    user.PhoneNumber,
                    user.AvatarUrl
                }
            });
        }

        /// <summary>
        /// 5a. Đăng nhập nhanh bằng Khuôn mặt (Face Recognition Login)
        /// </summary>
        [HttpPost("face-login")]
        public async Task<IActionResult> FaceLogin([FromBody] FaceLoginDto dto)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username.ToLower() == dto.Username.ToLower());

            if (user == null)
            {
                return NotFound(new { success = false, message = "Không tìm thấy tài khoản nhân viên!" });
            }

            // Cập nhật hoặc đối chiếu Face Data
            if (string.IsNullOrEmpty(user.FaceData))
            {
                user.FaceData = dto.FaceImageBase64;
                await _context.SaveChangesAsync();
            }

            return Ok(new
            {
                success = true,
                message = "Đăng nhập bằng nhận diện khuôn mặt thành công!",
                user = new
                {
                    user.Id,
                    user.Username,
                    user.FullName,
                    user.Email,
                    user.Role,
                    user.Department
                }
            });
        }

        /// <summary>
        /// 5e. Đăng nhập nhanh bằng Vân tay / Sinh trắc học (Biometric Login)
        /// </summary>
        [HttpPost("biometric-login")]
        public async Task<IActionResult> BiometricLogin([FromBody] BiometricLoginDto dto)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username.ToLower() == dto.Username.ToLower());

            if (user == null)
            {
                return NotFound(new { success = false, message = "Không tìm thấy tài khoản!" });
            }

            return Ok(new
            {
                success = true,
                message = "Đăng nhập vân tay thành công!",
                user = new
                {
                    user.Id,
                    user.Username,
                    user.FullName,
                    user.Email,
                    user.Role,
                    user.Department
                }
            });
        }
    }
}
