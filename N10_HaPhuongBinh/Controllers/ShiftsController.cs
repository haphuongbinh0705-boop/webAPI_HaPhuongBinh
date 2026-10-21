using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using N10_HaPhuongBinh.Models;

namespace N10_HaPhuongBinh.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ShiftsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public ShiftsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/Shifts
        [HttpGet]
        public async Task<IActionResult> GetShifts()
        {
            var shifts = await _context.Shifts.ToListAsync();
            return Ok(new { success = true, data = shifts });
        }

        // GET: api/Shifts/5
        [HttpGet("{id}")]
        public async Task<IActionResult> GetShift(int id)
        {
            var shift = await _context.Shifts.FindAsync(id);
            if (shift == null)
            {
                return NotFound(new { success = false, message = "Không tìm thấy ca làm việc!" });
            }
            return Ok(new { success = true, data = shift });
        }

        // POST: api/Shifts
        [HttpPost]
        public async Task<IActionResult> CreateShift([FromBody] Shift shift)
        {
            _context.Shifts.Add(shift);
            await _context.SaveChangesAsync();
            return CreatedAtAction(nameof(GetShift), new { id = shift.Id }, new { success = true, message = "Thêm ca làm việc thành công!", data = shift });
        }

        // PUT: api/Shifts/5
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateShift(int id, [FromBody] Shift shift)
        {
            var existing = await _context.Shifts.FindAsync(id);
            if (existing == null)
            {
                return NotFound(new { success = false, message = "Không tìm thấy ca làm việc!" });
            }

            existing.ShiftName = shift.ShiftName;
            existing.StartTime = shift.StartTime;
            existing.EndTime = shift.EndTime;
            existing.SalaryRate = shift.SalaryRate;
            existing.Description = shift.Description;

            await _context.SaveChangesAsync();
            return Ok(new { success = true, message = "Cập nhật ca làm việc thành công!", data = existing });
        }

        // DELETE: api/Shifts/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteShift(int id)
        {
            var shift = await _context.Shifts.FindAsync(id);
            if (shift == null)
            {
                return NotFound(new { success = false, message = "Không tìm thấy ca làm việc!" });
            }

            _context.Shifts.Remove(shift);
            await _context.SaveChangesAsync();
            return Ok(new { success = true, message = "Đã xóa ca làm việc!" });
        }
    }
}
