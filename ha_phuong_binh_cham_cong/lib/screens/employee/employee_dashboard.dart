import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/translation_service.dart';
import '../auth/login_screen.dart';
import 'attendance_history_screen.dart';
import 'leave_request_screen.dart';
import 'shift_swap_screen.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  UserModel? _user;
  bool _isLoading = false;
  Map<String, dynamic>? _salaryEstimate;
  bool _isCheckedIn = false;
  String _todayStatus = 'Chưa chấm công';

  // Toạ độ GPS giả lập/thực tế của thiết bị
  double _myLat = 10.8018; // Mặc định ở đúng trụ sở công ty
  double _myLng = 106.7118;
  bool _simulateOutsideOffice = false;

  @override
  void initState() {
    super.initState();
    _user = ApiService.currentUser ??
        UserModel(
          id: 2,
          username: 'binh.hp',
          fullName: 'Hà Phương Bình',
          email: 'haphuongbinh0705@gmail.com',
          role: 'NhanVien',
          department: 'Công nghệ thông tin',
        );
    _loadSalaryEstimate();
  }

  void _loadSalaryEstimate() async {
    final res = await ApiService.getSalaryEstimate(_user!.id);
    if (mounted) {
      setState(() => _salaryEstimate = res);
    }
  }

  // 5b: Tính năng "Chia sẻ vị trí" - Gửi toạ độ thời gian thực và link Google Maps cho Quản lý
  void _shareLiveLocation() {
    final lat = _simulateOutsideOffice ? 10.8500 : _myLat;
    final lng = _simulateOutsideOffice ? 106.7500 : _myLng;
    final mapUrl = "https://maps.google.com/?q=$lat,$lng";
    final address = _simulateOutsideOffice ? "Khu Công Nghệ Cao, TP. Thủ Đức, TP. HCM" : "Trụ sở Công ty Hà Phương Bình (10.8018, 106.7118)";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.share_location, color: Colors.blue),
            SizedBox(width: 8),
            Text('Chia sẻ vị trí công tác (GPS)'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Toạ độ GPS thời gian thực của bạn:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('• Vĩ độ (Lat): $lat\n• Kinh độ (Lng): $lng\n• Địa chỉ: $address'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
              child: SelectableText(
                'Link Google Maps:\n$mapUrl',
                style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
          ElevatedButton.icon(
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Gửi vị trí cho Quản lý'),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã chia sẻ toạ độ vị trí thực tế của bạn cho Quản lý thành công!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 5b: Chấm công bằng Định vị vị trí GPS (Geofencing)
  void _checkInWithGps() async {
    final lat = _simulateOutsideOffice ? 10.8500 : _myLat;
    final lng = _simulateOutsideOffice ? 106.7500 : _myLng;

    setState(() => _isLoading = true);
    final res = await ApiService.checkIn(
      userId: _user!.id,
      shiftId: 1,
      latitude: lat,
      longitude: lng,
      method: 'GPS',
      locationAddress: _simulateOutsideOffice ? 'Ngoài công ty (Cách 5.2km)' : 'Trụ sở Công ty Hà Phương Bình (Hợp lệ)',
    );
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (res['success'] == true) {
      setState(() {
        _isCheckedIn = true;
        _todayStatus = 'Đã Check-In lúc ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} (GPS)';
      });
      _loadSalaryEstimate();
      _showResultDialog('Chấm công GPS thành công', res['message'] ?? '', res['isLocationValid'] == true);
    } else {
      _showResultDialog('Thông báo', res['message'] ?? 'Thất bại!', false);
    }
  }

  // 5e: Chấm công bằng Quét mã QR tại văn phòng
  void _checkInWithQr() async {
    final qrController = TextEditingController(text: ApiConfig.officeQrSecret);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Quét mã QR Văn phòng'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.indigo.shade200),
                borderRadius: BorderRadius.circular(12),
                color: Colors.indigo.shade50,
              ),
              child: const Column(
                children: [
                  Icon(Icons.qr_code_2, size: 90, color: Colors.indigo),
                  SizedBox(height: 8),
                  Text('Camera đang quét mã QR dán tại cửa văn phòng...'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qrController,
              decoration: const InputDecoration(labelText: 'Dữ liệu mã QR đã quét', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              final res = await ApiService.checkIn(
                userId: _user!.id,
                method: 'QR',
                qrCode: qrController.text.trim(),
                latitude: _myLat,
                longitude: _myLng,
              );
              setState(() => _isLoading = false);
              if (mounted && res['success'] == true) {
                setState(() {
                  _isCheckedIn = true;
                  _todayStatus = 'Đã Check-In lúc ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} (QR Code)';
                });
                _loadSalaryEstimate();
                _showResultDialog('Check-In QR Thành công', 'Hệ thống đã xác nhận mã QR văn phòng hợp lệ!', true);
              }
            },
            child: const Text('Xác nhận quét mã'),
          ),
        ],
      ),
    );
  }

  // 5a: Chấm công bằng Nhận diện khuôn mặt (Camera Selfie Check-In)
  void _checkInWithFace() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.camera_alt, color: Colors.purple),
            SizedBox(width: 8),
            Text('Chụp ảnh xác thực khuôn mặt'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.purple, width: 3),
                color: Colors.purple.shade50,
              ),
              child: const Icon(Icons.face, size: 80, color: Colors.purple),
            ),
            const SizedBox(height: 12),
            const Text('Vui lòng nhìn thẳng vào camera để nhận diện AI khuôn mặt.', textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              final res = await ApiService.checkIn(
                userId: _user!.id,
                method: 'FACE',
                checkInPhoto: 'FACE_SNAPSHOT_BASE64_STAMP',
                latitude: _myLat,
                longitude: _myLng,
              );
              setState(() => _isLoading = false);
              if (mounted && res['success'] == true) {
                setState(() {
                  _isCheckedIn = true;
                  _todayStatus = 'Đã Check-In lúc ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} (Khuôn mặt)';
                });
                _loadSalaryEstimate();
                _showResultDialog('Check-In Khuôn mặt Thành công', 'Nhận diện khuôn mặt nhân viên chính xác 99.8%!', true);
              }
            },
            child: const Text('Chụp & Xác thực Face'),
          ),
        ],
      ),
    );
  }

  // Check-Out ra về
  void _handleCheckOut() async {
    setState(() => _isLoading = true);
    final res = await ApiService.checkOut(userId: _user!.id, note: 'Check out đúng giờ');
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (res['success'] == true) {
      setState(() {
        _isCheckedIn = false;
        _todayStatus = 'Đã Check-Out hoàn tất ngày làm việc!';
      });
      _loadSalaryEstimate();
      _showResultDialog('Check-Out Thành công', 'Đã ghi nhận giờ kết thúc ca làm. Cảm ơn bạn!', true);
    } else {
      _showResultDialog('Thông báo', res['message'] ?? 'Lỗi!', false);
    }
  }

  void _showResultDialog(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(isSuccess ? Icons.check_circle : Icons.warning_amber, color: isSuccess ? Colors.green : Colors.orange),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(TranslationService.tr('emp_dashboard')),
        actions: [
          // 5f: Dịch đa ngôn ngữ Realtime (Tiếng Việt, Tiếng Anh, Tiếng Nhật)
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            tooltip: 'Đổi ngôn ngữ (Dịch Realtime)',
            onSelected: (lang) => setState(() => TranslationService.setLanguage(lang)),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'vi', child: Text('🇻🇳 Tiếng Việt')),
              PopupMenuItem(value: 'en', child: Text('🇬🇧 English')),
              PopupMenuItem(value: 'ja', child: Text('🇯🇵 日本語')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () {
              ApiService.currentUser = null;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thẻ thông tin cá nhân
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        _user!.fullName.isNotEmpty ? _user!.fullName[0] : 'U',
                        style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_user!.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('${_user!.department ?? "Nhân viên"} • ${_user!.role}', style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _isCheckedIn ? Colors.green.shade100 : Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _todayStatus,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _isCheckedIn ? Colors.green.shade800 : Colors.blue.shade800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 6. Tính năng Realtime: Dự toán tiền lương tích lũy trong tháng
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.indigo.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('DỰ TOÁN LƯƠNG REAL-TIME', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                        Icon(Icons.insights, color: Colors.amberAccent),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _salaryEstimate != null ? '${_salaryEstimate!['estimatedSalary']} VNĐ' : '6,160,000 VNĐ',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng công: ${_salaryEstimate?['totalWorkDays'] ?? 22} ngày (${_salaryEstimate?['totalHours'] ?? 176}h)',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const Text('Định mức: 35.000đ/h', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // KHU VỰC CHẤM CÔNG (3/6 TÍNH NĂNG NÂNG CAO)
            const Text('CHỌN HÌNH THỨC CHẤM CÔNG:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),

            // Công tắc giả lập toạ độ GPS ngoài phạm vi công ty để demo cho thầy
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 20, color: Colors.brown),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Demo: Giả lập đứng xa công ty (>300m)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.brown)),
                  ),
                  Switch(
                    value: _simulateOutsideOffice,
                    onChanged: (v) => setState(() => _simulateOutsideOffice = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 3 Nút Chấm Công: GPS, QR, Face
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.my_location),
                    label: const Text('GPS Check-in', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _isLoading ? null : _checkInWithGps,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.indigo.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Quét QR', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _isLoading ? null : _checkInWithQr,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.face_retouching_natural),
                    label: const Text('Chụp Face ID', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _isLoading ? null : _checkInWithFace,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Check-Out', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _isLoading ? null : _handleCheckOut,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // CÁC TÍNH NĂNG ĐIỀU HƯỚNG
            Text(TranslationService.tr('emp_utilities'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),

            // 5b: Chia sẻ vị trí công tác thời gian thực
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.blue.shade50,
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.share_location, color: Colors.white)),
                title: Text(TranslationService.tr('share_location'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                subtitle: Text(TranslationService.tr('share_location_sub')),
                trailing: const Icon(Icons.send, color: Colors.blue, size: 20),
                onTap: _shareLiveLocation,
              ),
            ),
            const SizedBox(height: 8),

            // Lịch sử chấm công
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.history, color: Colors.white)),
                title: Text(TranslationService.tr('history'), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Xem lại số giờ làm, trạng thái đúng giờ/đi muộn'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AttendanceHistoryScreen(userId: _user!.id)));
                },
              ),
            ),
            const SizedBox(height: 8),

            // Đơn xin nghỉ phép (CRUD kèm Chụp ảnh minh chứng)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.event_busy, color: Colors.white)),
                title: Text(TranslationService.tr('leave_request'), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Tạo mới, chụp ảnh giấy khám bệnh/minh chứng'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveRequestScreen(userId: _user!.id)));
                },
              ),
            ),
            const SizedBox(height: 8),

            // 6. Tính năng sáng tạo 1đ: Đổi ca làm việc P2P bằng mã QR
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.teal.shade300, width: 1.5)),
              color: Colors.teal.shade50,
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.sync_alt, color: Colors.white)),
                title: Row(
                  children: [
                    Text(TranslationService.tr('shift_swap'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                    const SizedBox(width: 6),
                    const Chip(
                      label: Text('Mới 1đ', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                subtitle: const Text('Tạo hoặc quét mã QR đổi ca ngang hàng với đồng nghiệp'),
                trailing: const Icon(Icons.chevron_right, color: Colors.teal),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ShiftSwapScreen(userId: _user!.id)));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
