using Microsoft.EntityFrameworkCore;

namespace N10_HaPhuongBinh.Models
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; } = null!;
        public DbSet<Shift> Shifts { get; set; } = null!;
        public DbSet<AttendanceRecord> AttendanceRecords { get; set; } = null!;
        public DbSet<LeaveRequest> LeaveRequests { get; set; } = null!;
        public DbSet<ShiftSwap> ShiftSwaps { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Cấu hình khoá ngoại cho ShiftSwap tránh xung đột cascade delete
            modelBuilder.Entity<ShiftSwap>()
                .HasOne(s => s.Requester)
                .WithMany()
                .HasForeignKey(s => s.RequesterId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<ShiftSwap>()
                .HasOne(s => s.TargetUser)
                .WithMany()
                .HasForeignKey(s => s.TargetUserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<ShiftSwap>()
                .HasOne(s => s.CurrentShift)
                .WithMany()
                .HasForeignKey(s => s.CurrentShiftId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<ShiftSwap>()
                .HasOne(s => s.DesiredShift)
                .WithMany()
                .HasForeignKey(s => s.DesiredShiftId)
                .OnDelete(DeleteBehavior.Restrict);

            // Dữ liệu mẫu (Seed Data)
            modelBuilder.Entity<User>().HasData(
                new User
                {
                    Id = 1,
                    Username = "admin",
                    Password = "123", // Mật khẩu demo dễ nhớ
                    FullName = "Quản trị viên Hệ thống",
                    Email = "admin@company.com",
                    PhoneNumber = "0901234567",
                    Role = "Admin",
                    Department = "Ban Giám Đốc",
                    CreatedAt = new DateTime(2026, 1, 1)
                },
                new User
                {
                    Id = 2,
                    Username = "binh.hp",
                    Password = "123",
                    FullName = "Hà Phương Bình",
                    Email = "haphuongbinh0705@gmail.com",
                    PhoneNumber = "0912345678",
                    Role = "NhanVien",
                    Department = "Công nghệ thông tin",
                    CreatedAt = new DateTime(2026, 1, 1)
                },
                new User
                {
                    Id = 3,
                    Username = "manager",
                    Password = "123",
                    FullName = "Trần Trưởng Phòng",
                    Email = "manager@company.com",
                    PhoneNumber = "0987654321",
                    Role = "QuanLy",
                    Department = "Phòng Quản lý & Nhân sự",
                    CreatedAt = new DateTime(2026, 1, 1)
                },
                new User
                {
                    Id = 4,
                    Username = "khach",
                    Password = "123",
                    FullName = "Khách hàng Thử việc",
                    Email = "khach@gmail.com",
                    PhoneNumber = "0933445566",
                    Role = "Khach",
                    Department = "Khách vãng lai",
                    CreatedAt = new DateTime(2026, 1, 1)
                }
            );

            modelBuilder.Entity<Shift>().HasData(
                new Shift
                {
                    Id = 1,
                    ShiftName = "Ca Sáng",
                    StartTime = new TimeSpan(8, 0, 0),
                    EndTime = new TimeSpan(12, 0, 0),
                    SalaryRate = 1.0,
                    Description = "Ca làm việc buổi sáng (08:00 - 12:00)"
                },
                new Shift
                {
                    Id = 2,
                    ShiftName = "Ca Chiều",
                    StartTime = new TimeSpan(13, 30, 0),
                    EndTime = new TimeSpan(17, 30, 0),
                    SalaryRate = 1.0,
                    Description = "Ca làm việc buổi chiều (13:30 - 17:30)"
                },
                new Shift
                {
                    Id = 3,
                    ShiftName = "Ca Tối (Tăng ca)",
                    StartTime = new TimeSpan(18, 0, 0),
                    EndTime = new TimeSpan(22, 0, 0),
                    SalaryRate = 1.5,
                    Description = "Ca làm việc buổi tối tính hệ số 1.5x (18:00 - 22:00)"
                }
            );
        }
    }
}
