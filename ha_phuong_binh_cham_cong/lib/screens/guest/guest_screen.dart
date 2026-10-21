import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';

class GuestScreen extends StatelessWidget {
  const GuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang Khách hàng & Ứng viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ApiService.currentUser = null;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.apartment, size: 60, color: Colors.blue),
                    const SizedBox(height: 12),
                    const Text(
                      'CÔNG TY CÔNG NGHỆ HÀ PHƯƠNG BÌNH',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Chào mừng ${user?.fullName ?? "Quý khách"} đã đăng nhập hệ thống!',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('THÔNG TIN DOANH NGHIỆP:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.location_on, color: Colors.red),
              title: Text('Trụ sở chính'),
              subtitle: Text('Toà nhà Công nghệ, TP. Hồ Chí Minh (Toạ độ GPS: 10.8018, 106.7118)'),
            ),
            const ListTile(
              leading: Icon(Icons.access_time, color: Colors.orange),
              title: Text('Giờ làm việc tiêu chuẩn'),
              subtitle: Text('Thứ 2 - Thứ 6: 08:00 - 17:30 (Nghỉ trưa 12:00 - 13:30)'),
            ),
            const ListTile(
              leading: Icon(Icons.support_agent, color: Colors.green),
              title: Text('Liên hệ bộ phận tuyển dụng & nhân sự'),
              subtitle: Text('Hotline: 0901 234 567 - Email: tuyendung@company.com'),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.assignment),
              label: const Text('NỘP HỒ SƠ ỨNG TUYỂN / THỬ VIỆC', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hệ thống đã ghi nhận thông tin ứng tuyển của bạn!'), backgroundColor: Colors.green),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
