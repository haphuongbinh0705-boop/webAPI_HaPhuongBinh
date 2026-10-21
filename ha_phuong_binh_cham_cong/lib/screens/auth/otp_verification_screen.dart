import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../admin/admin_dashboard.dart';
import '../employee/employee_dashboard.dart';
import '../manager/manager_dashboard.dart';
import '../guest/guest_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String username;
  final String presetOtp;
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.username,
    required this.presetOtp,
    required this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late final TextEditingController _otpController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController(); // Để trống để nhập mã OTP thực tế từ Gmail
  }

  void _handleVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ 6 chữ số OTP!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final res = await ApiService.verifyOtp(username: widget.username, otpCode: otp);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (res['success'] == true) {
      final user = ApiService.currentUser!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xác thực thành công! Chào mừng ${user.fullName} (${user.role})'),
          backgroundColor: Colors.green,
        ),
      );

      // Phân quyền theo Role (Tiêu chí 3)
      Widget destination;
      switch (user.role) {
        case 'Admin':
          destination = const AdminDashboard();
          break;
        case 'QuanLy':
          destination = const ManagerDashboard();
          break;
        case 'Khach':
          destination = const GuestScreen();
          break;
        case 'NhanVien':
        default:
          destination = const EmployeeDashboard();
          break;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => destination),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Xác thực OTP thất bại!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Xác thực OTP 2 lớp')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.mark_email_read, size: 36, color: Colors.blue),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'XÁC THỰC MÃ OTP',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hệ thống đã gửi mã OTP 6 số đến email:\n${widget.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),

                    // Thông báo hướng dẫn mở hòm thư Gmail
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mark_email_unread_outlined, color: Colors.blue, size: 22),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Vui lòng mở ứng dụng Gmail để lấy mã OTP 6 số vừa được gửi tới.',
                              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: const TextStyle(fontSize: 28, letterSpacing: 8, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: '000000',
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isLoading ? null : _handleVerify,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('XÁC NHẬN VÀ TIẾP TỤC', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Quay lại đăng nhập'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
