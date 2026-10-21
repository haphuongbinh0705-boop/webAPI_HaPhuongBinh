namespace N10_HaPhuongBinh.Services
{
    public interface IEmailService
    {
        Task<bool> SendOtpEmailAsync(string toEmail, string fullName, string otpCode);
    }
}
