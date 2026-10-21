using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using N10_HaPhuongBinh.Models;

namespace N10_HaPhuongBinh.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public UsersController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/Users (Hỗ trợ tìm kiếm, lọc theo Phòng ban & Vai trò)
        [HttpGet]
        public async Task<IActionResult> GetUsers([FromQuery] string? search, [FromQuery] string? role, [FromQuery] string? department)
        {
            var query = _context.Users.AsQueryable();

            if (!string.IsNullOrEmpty(search))
            {
                query = query.Where(u => u.FullName.Contains(search) || u.Username.Contains(search) || u.Email.Contains(search));
            }

            if (!string.IsNullOrEmpty(role))
            {
                query = query.Where(u => u.Role == role);
            }

            if (!string.IsNullOrEmpty(department))
            {
                query = query.Where(u => u.Department == department);
            }

            var list = await query.Select(u => new
            {
                u.Id,
                u.Username,
                u.FullName,
                u.Email,
                u.PhoneNumber,
                u.Role,
                u.Department,
                u.CreatedAt
            }).ToListAsync();

            return Ok(new { success = true, count = list.Count, data = list });
        }

        // GET: api/Users/5
        [HttpGet("{id}")]
        public async Task<IActionResult> GetUser(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
            {
                return NotFound(new { success = false, message = "Không tìm thấy người dùng!" });
            }

            return Ok(new
            {
                success = true,
                data = new
                {
                    user.Id,
                    user.Username,
                    user.FullName,
                    user.Email,
                    user.PhoneNumber,
                    user.Role,
                    user.Department,
                    user.CreatedAt
                }
            });
        }

        // POST: api/Users (Thêm mới nhân viên)
        [HttpPost]
        public async Task<IActionResult> CreateUser([FromBody] User user)
        {
            if (await _context.Users.AnyAsync(u => u.Username.ToLower() == user.Username.ToLower()))
            {
                return BadRequest(new { success = false, message = "Tên đăng nhập đã tồn tại!" });
            }

            if (await _context.Users.AnyAsync(u => u.Email.ToLower() == user.Email.ToLower()))
            {
                return BadRequest(new { success = false, message = "Email đã tồn tại!" });
            }

            user.CreatedAt = DateTime.Now;
            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetUser), new { id = user.Id }, new { success = true, message = "Thêm người dùng thành công!", data = user });
        }

        // PUT: api/Users/5 (Cập nhật thông tin nhân viên)
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateUser(int id, [FromBody] User updated)
        {
            var existing = await _context.Users.FindAsync(id);
            if (existing == null)
            {
                return NotFound(new { success = false, message = "Không tìm thấy người dùng!" });
            }

            existing.FullName = updated.FullName;
            existing.Email = updated.Email;
            existing.PhoneNumber = updated.PhoneNumber;
            existing.Department = updated.Department;
            existing.Role = updated.Role;
            if (!string.IsNullOrEmpty(updated.Password))
            {
                existing.Password = updated.Password;
            }

            await _context.SaveChangesAsync();
            return Ok(new { success = true, message = "Cập nhật thông tin thành công!", data = existing });
        }

        // DELETE: api/Users/5 (Xóa người dùng)
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
            {
                return NotFound(new { success = false, message = "Không tìm thấy người dùng!" });
            }

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Đã xóa người dùng thành công!" });
        }
    }
}
