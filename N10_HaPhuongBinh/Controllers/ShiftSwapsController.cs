using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using N10_HaPhuongBinh.DTOs;
using N10_HaPhuongBinh.Models;

namespace N10_HaPhuongBinh.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ShiftSwapsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public ShiftSwapsController(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// 6. Tính năng mới: Tạo yêu cầu đổi ca P2P và sinh mã QR xác thực
        /// </summary>
        [HttpPost("create")]
        public async Task<IActionResult> CreateSwapRequest([FromBody] CreateShiftSwapDto dto)
        {
            var requester = await _context.Users.FindAsync(dto.RequesterId);
            var targetUser = await _context.Users.FindAsync(dto.TargetUserId);

            if (requester == null || targetUser == null)
            {
                return NotFound(new { success = false, message = "Không tìm thấy thông tin nhân viên!" });
            }

            var swap = new ShiftSwap
            {
                RequesterId = dto.RequesterId,
                TargetUserId = dto.TargetUserId,
                CurrentShiftId = dto.CurrentShiftId,
                DesiredShiftId = dto.DesiredShiftId,
                SwapDate = dto.SwapDate,
                SwapQrCode = "SWAP_" + Guid.NewGuid().ToString("N").Substring(0, 10).ToUpper(),
                Status = "ChoXacNhan",
                Note = dto.Note,
                CreatedAt = DateTime.Now
            };

            _context.ShiftSwaps.Add(swap);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                success = true,
                message = "Tạo yêu cầu đổi ca thành công! Vui lòng đưa mã QR cho đồng nghiệp quét để xác nhận.",
                data = new
                {
                    swap.Id,
                    swap.RequesterId,
                    swap.TargetUserId,
                    swap.SwapDate,
                    swap.SwapQrCode,
                    swap.Status
                }
            });
        }

        /// <summary>
        /// 6. Đồng nghiệp quét mã QR để chấp nhận đổi ca tức thì
        /// </summary>
        [HttpPost("confirm-by-qr")]
        public async Task<IActionResult> ConfirmByQr([FromBody] ConfirmShiftSwapDto dto)
        {
            var swap = await _context.ShiftSwaps
                .Include(s => s.Requester)
                .Include(s => s.TargetUser)
                .Include(s => s.CurrentShift)
                .Include(s => s.DesiredShift)
                .FirstOrDefaultAsync(s => s.SwapQrCode == dto.SwapQrCode);

            if (swap == null)
            {
                return NotFound(new { success = false, message = "Mã QR đổi ca không hợp lệ hoặc không tồn tại!" });
            }

            if (swap.Status != "ChoXacNhan")
            {
                return BadRequest(new { success = false, message = $"Yêu cầu đổi ca này đã ở trạng thái: {swap.Status}" });
            }

            if (swap.TargetUserId != dto.TargetUserId)
            {
                return BadRequest(new { success = false, message = "Bạn không phải là người nhận trong yêu cầu đổi ca này!" });
            }

            swap.Status = "DaXacNhan";
            await _context.SaveChangesAsync();

            return Ok(new
            {
                success = true,
                message = $"Đã xác nhận đổi ca thành công giữa {swap.Requester?.FullName} và {swap.TargetUser?.FullName}!",
                data = swap
            });
        }

        /// <summary>
        /// Lấy danh sách yêu cầu đổi ca của một nhân viên
        /// </summary>
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetUserSwaps(int userId)
        {
            var list = await _context.ShiftSwaps
                .Include(s => s.Requester)
                .Include(s => s.TargetUser)
                .Include(s => s.CurrentShift)
                .Include(s => s.DesiredShift)
                .Where(s => s.RequesterId == userId || s.TargetUserId == userId)
                .OrderByDescending(s => s.CreatedAt)
                .ToListAsync();

            return Ok(new { success = true, data = list });
        }
    }
}
