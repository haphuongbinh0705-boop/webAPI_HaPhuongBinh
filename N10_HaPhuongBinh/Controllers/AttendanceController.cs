using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using N10_HaPhuongBinh.DTOs;
using N10_HaPhuongBinh.Models;

namespace N10_HaPhuongBinh.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AttendanceController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly IConfiguration _config;

        public AttendanceController(ApplicationDbContext context, IConfiguration config)
        {
            _context = context;
            _config = config;
        }

        /// <summary>
        /// 5b, 5e, 5a: Chấm công Check-In (Hỗ trợ Định vị GPS, Quét QR và Nhận diện khuôn mặt)
        /// </summary>
        [HttpPost("check-in")]
        public async Task<IActionResult> CheckIn([FromBody] CheckInDto dto)
        {
            var user = await _context.Users.FindAsync(dto.UserId);
            if (user == null)
            {
                return NotFound(new { success = false, message = "Không tìm thấy nhân viên!" });
            }

            var today = DateTime.Today;
            // Kiểm tra xem hôm nay đã check in chưa
            var existingRecord = await _context.AttendanceRecords
                .FirstOrDefaultAsync(a => a.UserId == dto.UserId && a.Date == today);

            if (existingRecord != null && existingRecord.CheckInTime != null)
            {
                return BadRequest(new { success = false, message = "Bạn đã thực hiện Check-In hôm nay rồi!" });
            }

            // 1. Kiểm tra vị trí GPS (Geofencing - Tính khoảng cách đến công ty)
            double companyLat = _config.GetValue<double>("CompanyLocation:Latitude", 10.8018);
            double companyLng = _config.GetValue<double>("CompanyLocation:Longitude", 106.7118);
            double allowedRadius = _config.GetValue<double>("CompanyLocation:AllowedRadiusMeters", 300);

            bool isLocationValid = true;
            double distanceMeters = 0;

            if (dto.Latitude.HasValue && dto.Longitude.HasValue)
            {
                distanceMeters = CalculateDistance(companyLat, companyLng, dto.Latitude.Value, dto.Longitude.Value);
                // Nếu vượt quá bán kính cho phép thì đánh dấu cảnh báo
                isLocationValid = distanceMeters <= allowedRadius;
            }

            // 2. Xác thực mã QR nếu phương thức là QR
            string officeSecret = _config.GetValue<string>("CompanyLocation:OfficeQrSecret") ?? "N10_CHAM_CONG_OFFICE_2026";
            if (dto.Method == "QR" && !string.IsNullOrEmpty(dto.QrCode))
            {
                if (!dto.QrCode.Contains(officeSecret))
                {
                    return BadRequest(new { success = false, message = "Mã QR tại văn phòng không hợp lệ hoặc đã hết hạn!" });
                }
            }

            var record = existingRecord ?? new AttendanceRecord
            {
                UserId = dto.UserId,
                ShiftId = dto.ShiftId ?? 1,
                Date = today
            };

            record.CheckInTime = DateTime.Now;
            record.Latitude = dto.Latitude;
            record.Longitude = dto.Longitude;
            record.LocationAddress = dto.LocationAddress ?? (isLocationValid ? "Văn phòng công ty (Hợp lệ)" : $"Ngoài phạm vi công ty ({Math.Round(distanceMeters)}m)");
            record.IsLocationValid = isLocationValid;
            record.Method = dto.Method; // "GPS", "QR", "FACE", "FINGERPRINT"
            record.CheckInPhoto = dto.CheckInPhoto;
            record.Note = dto.Note;

            // Xác định đúng giờ hay đi muộn (so với 08:30)
            if (DateTime.Now.TimeOfDay > new TimeSpan(8, 30, 0))
            {
                record.Status = "DiMuon";
            }
            else
            {
                record.Status = "DungGio";
            }

            if (existingRecord == null)
            {
                _context.AttendanceRecords.Add(record);
            }

            await _context.SaveChangesAsync();

            return Ok(new
            {
                success = true,
                message = isLocationValid ? "Chấm công Check-In thành công!" : $"Check-In thành công nhưng hệ thống ghi nhận bạn cách văn phòng {Math.Round(distanceMeters)}m!",
                isLocationValid,
                distanceMeters = Math.Round(distanceMeters),
                data = record
            });
        }

        /// <summary>
        /// Chấm công Check-Out kết thúc ca làm
        /// </summary>
        [HttpPost("check-out")]
        public async Task<IActionResult> CheckOut([FromBody] CheckOutDto dto)
        {
            var today = DateTime.Today;
            var record = await _context.AttendanceRecords
                .FirstOrDefaultAsync(a => a.UserId == dto.UserId && a.Date == today);

            if (record == null || record.CheckInTime == null)
            {
                return BadRequest(new { success = false, message = "Bạn chưa thực hiện Check-In hôm nay!" });
            }

            if (record.CheckOutTime != null)
            {
                return BadRequest(new { success = false, message = "Bạn đã Check-Out hôm nay rồi!" });
            }

            record.CheckOutTime = DateTime.Now;
            if (!string.IsNullOrEmpty(dto.Note))
            {
                record.Note = string.IsNullOrEmpty(record.Note) ? dto.Note : $"{record.Note} | Out: {dto.Note}";
            }

            await _context.SaveChangesAsync();

            // Tính số giờ làm
            var duration = (record.CheckOutTime.Value - record.CheckInTime.Value).TotalHours;

            return Ok(new
            {
                success = true,
                message = "Chấm công Check-Out thành công!",
                totalHours = Math.Round(duration, 2),
                data = record
            });
        }

        /// <summary>
        /// Xem lịch sử chấm công của 1 nhân viên
        /// </summary>
        [HttpGet("history/{userId}")]
        public async Task<IActionResult> GetUserHistory(int userId, [FromQuery] int? month, [FromQuery] int? year)
        {
            var m = month ?? DateTime.Now.Month;
            var y = year ?? DateTime.Now.Year;

            var list = await _context.AttendanceRecords
                .Include(a => a.Shift)
                .Where(a => a.UserId == userId && a.Date.Month == m && a.Date.Year == y)
                .OrderByDescending(a => a.Date)
                .ToListAsync();

            return Ok(new { success = true, month = m, year = y, count = list.Count, data = list });
        }

        /// <summary>
        /// Xem danh sách chấm công toàn công ty hôm nay (Cho Admin/Quản lý)
        /// </summary>
        [HttpGet("today")]
        public async Task<IActionResult> GetTodayAttendance()
        {
            var today = DateTime.Today;
            var list = await _context.AttendanceRecords
                .Include(a => a.User)
                .Include(a => a.Shift)
                .Where(a => a.Date == today)
                .OrderByDescending(a => a.CheckInTime)
                .Select(a => new
                {
                    a.Id,
                    a.UserId,
                    UserName = a.User != null ? a.User.FullName : "",
                    Department = a.User != null ? a.User.Department : "",
                    ShiftName = a.Shift != null ? a.Shift.ShiftName : "",
                    a.CheckInTime,
                    a.CheckOutTime,
                    a.Method,
                    a.Status,
                    a.IsLocationValid,
                    a.CheckInPhoto
                }).ToListAsync();

            return Ok(new { success = true, today = today.ToString("yyyy-MM-dd"), total = list.Count, data = list });
        }

        /// <summary>
        /// Tính năng Realtime: Dự toán tiền lương và số công tích lũy trong tháng
        /// </summary>
        [HttpGet("salary-estimate/{userId}")]
        public async Task<IActionResult> GetSalaryEstimate(int userId)
        {
            var currentMonth = DateTime.Now.Month;
            var currentYear = DateTime.Now.Year;

            var records = await _context.AttendanceRecords
                .Include(a => a.Shift)
                .Where(a => a.UserId == userId && a.Date.Month == currentMonth && a.Date.Year == currentYear)
                .ToListAsync();

            double totalWorkDays = records.Count(r => r.CheckInTime.HasValue);
            double totalHours = 0;
            double estimatedSalary = 0;
            double hourlyRate = 35000; // 35.000 VNĐ / giờ tiêu chuẩn

            foreach (var r in records)
            {
                if (r.CheckInTime.HasValue && r.CheckOutTime.HasValue)
                {
                    double hours = (r.CheckOutTime.Value - r.CheckInTime.Value).TotalHours;
                    double rate = r.Shift?.SalaryRate ?? 1.0;
                    totalHours += hours;
                    estimatedSalary += hours * hourlyRate * rate;
                }
                else if (r.CheckInTime.HasValue)
                {
                    // Đang làm việc tạm tính 4 tiếng nửa ca
                    totalHours += 4.0;
                    estimatedSalary += 4.0 * hourlyRate;
                }
            }

            return Ok(new
            {
                success = true,
                month = currentMonth,
                year = currentYear,
                totalWorkDays,
                totalHours = Math.Round(totalHours, 1),
                hourlyRate,
                estimatedSalary = Math.Round(estimatedSalary)
            });
        }

        /// <summary>
        /// Lấy thông tin mã QR của văn phòng để hiển thị/quét
        /// </summary>
        [HttpGet("office-qr")]
        public IActionResult GetOfficeQr()
        {
            string secret = _config.GetValue<string>("CompanyLocation:OfficeQrSecret") ?? "N10_CHAM_CONG_OFFICE_2026";
            double lat = _config.GetValue<double>("CompanyLocation:Latitude", 10.8018);
            double lng = _config.GetValue<double>("CompanyLocation:Longitude", 106.7118);

            return Ok(new
            {
                success = true,
                qrData = $"{secret}|LAT:{lat}|LNG:{lng}|TIME:{DateTime.Now:yyyyMMdd}",
                companyName = "Trụ sở Công ty Hà Phương Bình",
                latitude = lat,
                longitude = lng
            });
        }

        // Công thức Haversine tính khoảng cách giữa 2 toạ độ GPS (đơn vị: mét)
        private double CalculateDistance(double lat1, double lon1, double lat2, double lon2)
        {
            const double R = 6371000; // Bán kính trái đất tính bằng mét
            double dLat = ToRadians(lat2 - lat1);
            double dLon = ToRadians(lon2 - lon1);

            double a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                       Math.Cos(ToRadians(lat1)) * Math.Cos(ToRadians(lat2)) *
                       Math.Sin(dLon / 2) * Math.Sin(dLon / 2);

            double c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
            return R * c;
        }

        private double ToRadians(double angle)
        {
            return Math.PI * angle / 180.0;
        }
    }
}
