using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using N10_HaPhuongBinh.DTOs;
using N10_HaPhuongBinh.Models;

namespace N10_HaPhuongBinh.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LeaveRequestsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public LeaveRequestsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/LeaveRequests (Dành cho Admin/Quản lý xem toàn bộ đơn)
        [HttpGet]
        public async Task<IActionResult> GetAllLeaveRequests([FromQuery] string? status)
        {
            var query = _context.LeaveRequests
                .Include(r => r.User)
                .AsQueryable();

            if (!string.IsNullOrEmpty(status))
            {
                query = query.Where(r => r.Status == status);
            }

            var list = await query
                .OrderByDescending(r => r.CreatedAt)
                .Select(r => new
                {
                    r.Id,
                    r.UserId,
                    UserName = r.User != null ? r.User.FullName : "",
                    r.LeaveType,
                    r.FromDate,
                    r.ToDate,
                    r.Reason,
                    r.Status,
                    r.AdminComment,
                    r.CreatedAt
                }).ToListAsync();

            return Ok(new { success = true, count = list.Count, data = list });
        }

        // GET: api/LeaveRequests/user/2 (Lấy đơn của một nhân viên cụ thể)
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetUserLeaveRequests(int userId)
        {
            var list = await _context.LeaveRequests
                .Where(r => r.UserId == userId)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();

            return Ok(new { success = true, data = list });
        }

        // POST: api/LeaveRequests (Nhân viên tạo đơn xin nghỉ)
        [HttpPost]
        public async Task<IActionResult> CreateLeaveRequest([FromBody] CreateLeaveRequestDto dto)
        {
            var user = await _context.Users.FindAsync(dto.UserId);
            if (user == null)
            {
                return NotFound(new { success = false, message = "Người dùng không tồn tại!" });
            }

            var request = new LeaveRequest
            {
                UserId = dto.UserId,
                LeaveType = dto.LeaveType,
                FromDate = dto.FromDate,
                ToDate = dto.ToDate,
                Reason = dto.Reason,
                Status = "ChoDuyet",
                CreatedAt = DateTime.Now
            };

            _context.LeaveRequests.Add(request);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Nộp đơn xin nghỉ phép thành công!", data = request });
        }

        // PUT: api/LeaveRequests/5/status (Quản lý/Admin duyệt hoặc từ chối)
        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateStatus(int id, [FromBody] UpdateLeaveStatusDto dto)
        {
            var req = await _context.LeaveRequests.FindAsync(id);
            if (req == null)
            {
                return NotFound(new { success = false, message = "Không tìm thấy đơn nghỉ phép!" });
            }

            req.Status = dto.Status; // "DaDuyet", "TuChoi"
            req.AdminComment = dto.AdminComment;

            await _context.SaveChangesAsync();
            return Ok(new { success = true, message = $"Đã cập nhật trạng thái đơn thành: {dto.Status}", data = req });
        }

        // DELETE: api/LeaveRequests/5 (Hủy đơn khi chưa được duyệt)
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteLeaveRequest(int id)
        {
            var req = await _context.LeaveRequests.FindAsync(id);
            if (req == null)
            {
                return NotFound(new { success = false, message = "Không tìm thấy đơn nghỉ phép!" });
            }

            if (req.Status != "ChoDuyet")
            {
                return BadRequest(new { success = false, message = "Đơn đã được xử lý, không thể xóa/hủy!" });
            }

            _context.LeaveRequests.Remove(req);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Đã hủy đơn nghỉ phép thành công!" });
        }
    }
}
