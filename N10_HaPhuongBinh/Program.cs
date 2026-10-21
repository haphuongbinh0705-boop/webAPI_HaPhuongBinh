using Microsoft.EntityFrameworkCore;
using N10_HaPhuongBinh.Models;
using N10_HaPhuongBinh.Services;

var builder = WebApplication.CreateBuilder(args);

// Lắng nghe tất cả các IP (bao gồm cả Máy ảo Android 10.0.2.2 và mạng LAN)
builder.WebHost.UseUrls("http://0.0.0.0:5121");

// 1. Cấu hình DbContext kết nối SQL Server (SQLEXPRESS)
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Dịch vụ gửi Email qua Gmail
builder.Services.AddScoped<IEmailService, EmailService>();

// 2. Cấu hình CORS để Ứng dụng Flutter kết nối thoải mái từ Web, Emulator hay Thiết bị thật
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

builder.Services.AddControllers();

// 3. Cấu hình Swagger UI trực quan
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
    {
        Title = "Hà Phương Bình - API Hệ thống Chấm công Nhân viên",
        Version = "v1",
        Description = "ASP.NET Core Web API phục vụ Đề thi Chấm công Di động - Hà Phương Bình (2380600198)"
    });
});

var app = builder.Build();

// 4. Tự động kiểm tra và tạo CSDL (EnsureCreated) kèm dữ liệu mẫu
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    try
    {
        context.Database.EnsureCreated();
        Console.WriteLine(">>> Database N10_ChamCongDB đã sẵn sàng và được khởi tạo thành công!");
    }
    catch (Exception ex)
    {
        Console.WriteLine($">>> Lỗi khởi tạo Database: {ex.Message}");
    }
}

// 5. Kích hoạt Swagger UI cho cả Development và Production để dễ demo
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "Hà Phương Bình - Chấm Công API v1");
    c.RoutePrefix = string.Empty; // Mở trực tiếp http://localhost:PORT là ra Swagger UI
});

app.UseCors("AllowAll");

// Cho phép HTTP để mobile kết nối dễ dàng không bị chặn chứng chỉ SSL tự ký
// app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
