using System.Net;
using System.Net.Mail;

namespace N10_HaPhuongBinh.Services
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _config;
        private readonly ILogger<EmailService> _logger;

        public EmailService(IConfiguration config, ILogger<EmailService> logger)
        {
            _config = config;
            _logger = logger;
        }

        public async Task<bool> SendOtpEmailAsync(string toEmail, string fullName, string otpCode)
        {
            try
            {
                var smtpServer = _config["EmailSettings:SmtpServer"] ?? "smtp.gmail.com";
                var port = int.Parse(_config["EmailSettings:Port"] ?? "587");
                var senderEmail = _config["EmailSettings:SenderEmail"] ?? "";
                var senderPassword = _config["EmailSettings:SenderPassword"] ?? "";
                var senderName = _config["EmailSettings:SenderName"] ?? "Hệ Thống Chấm Công - Hà Phương Bình";

                if (string.IsNullOrEmpty(senderEmail) || string.IsNullOrEmpty(senderPassword))
                {
                    _logger.LogWarning("Chưa cấu hình EmailSettings:SenderEmail hoặc SenderPassword trong appsettings.json.");
                    return false;
                }

                using var message = new MailMessage();
                message.From = new MailAddress(senderEmail, senderName);
                message.To.Add(new MailAddress(toEmail));
                message.Subject = $"[{otpCode}] Mã xác thực OTP đăng nhập Hệ thống Chấm công";
                message.IsBodyHtml = true;
                message.Body = $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
</head>
<body style='font-family: Arial, sans-serif; background-color: #f4f6f9; margin: 0; padding: 20px;'>
    <div style='max-width: 580px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.08);'>
        <div style='background: linear-gradient(135deg, #1976D2, #0D47A1); padding: 25px 20px; text-align: center; color: #ffffff;'>
            <h1 style='margin: 0; font-size: 22px; letter-spacing: 0.5px;'>HỆ THỐNG CHẤM CÔNG NHÂN VIÊN</h1>
            <p style='margin: 6px 0 0; opacity: 0.85; font-size: 14px;'>Xác thực đăng nhập tài khoản 2 lớp (OTP)</p>
        </div>
        <div style='padding: 30px 25px;'>
            <p style='font-size: 16px; margin: 0 0 15px; color: #333333;'>Xin chào <strong>{fullName}</strong>,</p>
            <p style='font-size: 15px; color: #555555; line-height: 1.6; margin: 0 0 25px;'>
                Bạn vừa thực hiện yêu cầu đăng nhập vào <strong>Hệ thống Chấm công - Hà Phương Bình (MSSV: 2380600198)</strong>. Vui lòng sử dụng mã OTP dưới đây để hoàn tất đăng nhập:
            </p>
            <div style='text-align: center; margin: 25px 0;'>
                <div style='display: inline-block; background-color: #E3F2FD; border: 2px dashed #1976D2; border-radius: 12px; padding: 14px 35px;'>
                    <span style='font-size: 36px; font-weight: bold; letter-spacing: 8px; color: #0D47A1;'>{otpCode}</span>
                </div>
            </div>
            <p style='font-size: 13px; color: #777777; text-align: center; margin: 20px 0 0;'>
                ⏰ Mã OTP này có hiệu lực trong vòng <strong>5 phút</strong>.<br>
                🔒 Vui lòng không chia sẻ mã này cho bất kỳ ai để bảo vệ tài khoản của bạn.
            </p>
        </div>
        <div style='background-color: #f8f9fa; padding: 15px; text-align: center; font-size: 12px; color: #888888; border-top: 1px solid #eeeeee;'>
            Email tự động từ Đề tài Chấm công Di động - Sinh viên: Hà Phương Bình (Nhóm 10)
        </div>
    </div>
</body>
</html>";

                using var client = new SmtpClient(smtpServer, port);
                client.Credentials = new NetworkCredential(senderEmail, senderPassword);
                client.EnableSsl = true;

                await client.SendMailAsync(message);
                _logger.LogInformation($"[GMAIL] Đã gửi mã OTP {otpCode} thành công đến {toEmail}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"[GMAIL LỖI] Không thể gửi email đến {toEmail}: {ex.Message}");
                return false;
            }
        }
    }
}
