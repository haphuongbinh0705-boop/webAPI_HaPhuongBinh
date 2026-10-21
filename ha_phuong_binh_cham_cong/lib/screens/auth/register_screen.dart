import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = 'NhanVien';
  String _selectedDepartment = 'Công nghệ thông tin';
  bool _isLoading = false;

  final List<String> _departments = [
    'Công nghệ thông tin',
    'Phòng Kế toán & Tài chính',
    'Phòng Nhân sự',
    'Phòng Marketing',
    'Ban Quản trị',
  ];

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final res = await ApiService.register(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      role: _selectedRole,
      department: _selectedDepartment,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (res['success'] == true) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Đăng ký thành công!'),
          content: Text('Tài khoản đã được tạo với Email: ${_emailController.text.trim()}. Bạn có thể đăng nhập ngay bây giờ.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Đăng nhập ngay'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Đăng ký thất bại!'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('1. Đăng ký tài khoản qua Email')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'TẠO TÀI KHOẢN MỚI',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      const SizedBox(height: 20),

                      // Họ tên
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(labelText: 'Họ và tên *', prefixIcon: Icon(Icons.badge_outlined), border: OutlineInputBorder()),
                        validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập họ tên' : null,
                      ),
                      const SizedBox(height: 14),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email xác thực *', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Vui lòng nhập email';
                          if (!v.contains('@') || !v.contains('.')) return 'Email không đúng định dạng';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Tên đăng nhập
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: 'Tên đăng nhập *', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder()),
                        validator: (v) => v == null || v.length < 3 ? 'Tên đăng nhập ít nhất 3 ký tự' : null,
                      ),
                      const SizedBox(height: 14),

                      // Mật khẩu
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Mật khẩu *', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()),
                        validator: (v) => v == null || v.length < 3 ? 'Mật khẩu ít nhất 3 ký tự' : null,
                      ),
                      const SizedBox(height: 14),

                      // Số điện thoại
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Số điện thoại', prefixIcon: Icon(Icons.phone_outlined), border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),

                      // Vai trò (Role)
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(labelText: 'Phân quyền người dùng', prefixIcon: Icon(Icons.security), border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'NhanVien', child: Text('Nhân viên')),
                          DropdownMenuItem(value: 'Admin', child: Text('Quản trị viên (Admin)')),
                          DropdownMenuItem(value: 'QuanLy', child: Text('Quản lý bộ phận')),
                          DropdownMenuItem(value: 'Khach', child: Text('Khách hàng / Thử việc')),
                        ],
                        onChanged: (v) => setState(() => _selectedRole = v!),
                      ),
                      const SizedBox(height: 14),

                      // Phòng ban
                      DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        decoration: const InputDecoration(labelText: 'Phòng ban', prefixIcon: Icon(Icons.business), border: OutlineInputBorder()),
                        items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                        onChanged: (v) => setState(() => _selectedDepartment = v!),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isLoading ? null : _handleRegister,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('HOÀN TẤT ĐĂNG KÝ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
