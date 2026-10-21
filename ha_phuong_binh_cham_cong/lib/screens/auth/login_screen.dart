import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import 'otp_verification_screen.dart';
import 'register_screen.dart';
import '../admin/admin_dashboard.dart';
import '../employee/employee_dashboard.dart';
import '../manager/manager_dashboard.dart';
import '../guest/guest_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController(text: 'binh.hp');
  final _passwordController = TextEditingController(text: '123');
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên đăng nhập và mật khẩu!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final res = await ApiService.login(username: username, password: password);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (res['success'] == true) {
      final otp = res['otpCode']?.toString() ?? '888888';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            username: username,
            presetOtp: otp,
            email: res['email'] ?? 'haphuongbinh0705@gmail.com',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Đăng nhập thất bại!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 5a. Đăng nhập nhanh bằng Khuôn mặt (Face ID Simulation / Demo)
  void _handleFaceLogin() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.face_retouching_natural, color: Colors.blue),
            SizedBox(width: 8),
            Text('Nhận diện khuôn mặt'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueAccent, width: 3),
                color: Colors.blue.shade50,
              ),
              child: const Icon(Icons.person, size: 70, color: Colors.blue),
            ),
            const SizedBox(height: 16),
            const Text('Đang quét và đối chiếu đặc trưng khuôn mặt...', textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              final res = await ApiService.faceLogin(
                username: _usernameController.text.trim().isEmpty ? 'binh.hp' : _usernameController.text.trim(),
                faceBase64: 'BASE64_FACE_HASH_DEMO',
              );
              setState(() => _isLoading = false);
              if (mounted && res['success'] == true) {
                _navigateByRole(ApiService.currentUser!.role);
              }
            },
            child: const Text('Xác nhận Face ID'),
          ),
        ],
      ),
    );
  }

  // 5e. Đăng nhập bằng Vân tay (Biometrics)
  void _handleBiometricLogin() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.fingerprint, color: Colors.teal),
            SizedBox(width: 8),
            Text('Xác thực vân tay'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.teal.shade50,
                border: Border.all(color: Colors.teal, width: 2),
              ),
              child: const Icon(Icons.fingerprint, size: 60, color: Colors.teal),
            ),
            const SizedBox(height: 16),
            const Text('Chạm vào cảm biến vân tay trên thiết bị để đăng nhập nhanh.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              final res = await ApiService.biometricLogin(
                username: _usernameController.text.trim().isEmpty ? 'binh.hp' : _usernameController.text.trim(),
              );
              setState(() => _isLoading = false);
              if (mounted && res['success'] == true) {
                _navigateByRole(ApiService.currentUser!.role);
              }
            },
            child: const Text('Mô phỏng Chạm vân tay'),
          ),
        ],
      ),
    );
  }

  void _navigateByRole(String role) {
    Widget destination;
    switch (role) {
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
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => destination));
  }

  void _fillSampleUser(String username, String pass) {
    setState(() {
      _usernameController.text = username;
      _passwordController.text = pass;
    });
  }

  void _showApiSettings() {
    final controller = TextEditingController(text: ApiConfig.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cấu hình API Backend'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Địa chỉ máy chủ Web API (ASP.NET Core):', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'http://localhost:5121'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => ApiConfig.baseUrl = controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Hà Phương Bình - Chấm Công'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Cài đặt kết nối API',
            onPressed: _showApiSettings,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo & Tiêu đề
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(Icons.fingerprint, size: 44, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'HỆ THỐNG CHẤM CÔNG',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Đăng nhập tài khoản & mã OTP để bắt đầu',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Tên đăng nhập
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên đăng nhập',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mật khẩu
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nút Đăng nhập
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('ĐĂNG NHẬP & NHẬN OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),

                    // 5a & 5e: Đăng nhập sinh trắc học
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.face_retouching_natural, color: Colors.blue),
                            label: const Text('Face ID'),
                            onPressed: _handleFaceLogin,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.fingerprint, color: Colors.teal),
                            label: const Text('Vân tay'),
                            onPressed: _handleBiometricLogin,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Chọn nhanh tài khoản demo cho thầy / hội đồng chấm
                    const Divider(),
                    const Text(
                      'Tài khoản mẫu để test nhanh phân quyền:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.admin_panel_settings, size: 16, color: Colors.red),
                          label: const Text('Admin', style: TextStyle(fontSize: 12)),
                          onPressed: () => _fillSampleUser('admin', '123'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.badge, size: 16, color: Colors.blue),
                          label: const Text('Nhân viên (Bình)', style: TextStyle(fontSize: 12)),
                          onPressed: () => _fillSampleUser('binh.hp', '123'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.supervisor_account, size: 16, color: Colors.orange),
                          label: const Text('Quản lý', style: TextStyle(fontSize: 12)),
                          onPressed: () => _fillSampleUser('manager', '123'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.person, size: 16, color: Colors.green),
                          label: const Text('Khách', style: TextStyle(fontSize: 12)),
                          onPressed: () => _fillSampleUser('khach', '123'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    // 1. Đăng ký tài khoản qua email
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('Chưa có tài khoản? '),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            );
                          },
                          child: const Text('Đăng ký qua Email', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
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
