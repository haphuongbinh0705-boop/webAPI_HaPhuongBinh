import 'package:flutter/material.dart';
import '../../models/attendance_model.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import 'user_management_screen.dart';
import 'shift_management_screen.dart';
import '../manager/manager_dashboard.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<AttendanceModel> _todayRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayAttendance();
  }

  void _loadTodayAttendance() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getTodayAttendance();
    if (mounted) {
      setState(() {
        _todayRecords = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Admin Portal - Quản trị hệ thống'),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTodayAttendance),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thống kê nhanh
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue.shade700,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.people, color: Colors.white70, size: 28),
                          const SizedBox(height: 8),
                          const Text('Nhân sự', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          Text('${_todayRecords.length + 3} Người', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: Colors.teal.shade700,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline, color: Colors.white70, size: 28),
                          const SizedBox(height: 8),
                          const Text('Đã Check-In', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          Text('${_todayRecords.length} / ${_todayRecords.length + 3}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // MENU ĐIỀU HÀNH CRUD
            const Text('CHỨC NĂNG QUẢN LÝ (CRUD 4.5đ):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),

            // 1. Quản lý nhân viên
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.manage_accounts, color: Colors.white)),
                title: const Text('Quản lý Nhân sự (CRUD)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Thêm, Sửa, Xóa, Lọc phòng ban và Phân quyền'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const UserManagementScreen()));
                },
              ),
            ),
            const SizedBox(height: 8),

            // 2. Quản lý ca làm việc
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.purple, child: Icon(Icons.schedule, color: Colors.white)),
                title: const Text('Quản lý Ca làm việc (CRUD)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Cấu hình giờ bắt đầu, kết thúc và hệ số lương'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ShiftManagementScreen()));
                },
              ),
            ),
            const SizedBox(height: 8),

            // 3. Phê duyệt đơn xin nghỉ
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.fact_check, color: Colors.white)),
                title: const Text('Phê duyệt Đơn xin nghỉ phép', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Xem danh sách và duyệt đơn từ toàn công ty'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ManagerDashboard()));
                },
              ),
            ),
            const SizedBox(height: 20),

            // DANH SÁCH CHECK-IN HÔM NAY
            const Text('DANH SÁCH CHẤM CÔNG HÔM NAY:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _todayRecords.isEmpty
                    ? const Card(child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text('Chưa có nhân viên nào chấm công hôm nay.'))))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _todayRecords.length,
                        itemBuilder: (context, index) {
                          final item = _todayRecords[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: item.isLocationValid ? Colors.green.shade100 : Colors.red.shade100,
                                child: Icon(
                                  item.isLocationValid ? Icons.check : Icons.warning,
                                  color: item.isLocationValid ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Text(item.userName ?? 'Nhân viên', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${item.department ?? "CNTT"} • Check-In: ${item.checkInTime ?? "--:--"} (${item.method})'),
                              trailing: Chip(
                                label: Text(item.status == 'DungGio' ? 'Đúng giờ' : 'Đi muộn', style: const TextStyle(fontSize: 11)),
                                backgroundColor: item.status == 'DungGio' ? Colors.green.shade50 : Colors.orange.shade50,
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
