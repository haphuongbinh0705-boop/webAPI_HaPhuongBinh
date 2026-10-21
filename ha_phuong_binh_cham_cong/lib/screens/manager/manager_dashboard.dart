import 'package:flutter/material.dart';
import '../../models/leave_request_model.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  List<LeaveRequestModel> _allLeaves = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaves();
  }

  void _loadLeaves() async {
    setState(() => _isLoading = true);
    final list = await ApiService.getLeaveRequests();
    if (mounted) {
      setState(() {
        _allLeaves = list;
        _isLoading = false;
      });
    }
  }

  void _handleReview(LeaveRequestModel req, String status) {
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(status == 'DaDuyet' ? 'Phê duyệt đơn nghỉ phép' : 'Từ chối đơn nghỉ phép'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nhân viên: ${req.userName ?? "Nhân viên"}'),
            Text('Lý do: ${req.reason}'),
            const SizedBox(height: 12),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(labelText: 'Ý kiến / Ghi chú của quản lý', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'DaDuyet' ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ApiService.updateLeaveStatus(req.id, status, commentController.text.trim());
              _loadLeaves();
            },
            child: Text(status == 'DaDuyet' ? 'Chấp thuận' : 'Từ chối'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Portal Quản lý - Phê duyệt đơn'),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadLeaves),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ApiService.currentUser = null;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allLeaves.isEmpty
              ? const Center(child: Text('Hiện không có đơn xin nghỉ phép nào cần xử lý.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _allLeaves.length,
                  itemBuilder: (context, index) {
                    final item = _allLeaves[index];
                    final isPending = item.status == 'ChoDuyet';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item.userName ?? 'Nhân viên', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Chip(
                                  label: Text(
                                    item.status == 'DaDuyet' ? 'Đã duyệt' : item.status == 'TuChoi' ? 'Từ chối' : 'Chờ duyệt',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: item.status == 'DaDuyet'
                                      ? Colors.green.shade100
                                      : item.status == 'TuChoi'
                                          ? Colors.red.shade100
                                          : Colors.orange.shade100,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Loại nghỉ: ${item.leaveType} (${item.fromDate} đến ${item.toDate})', style: const TextStyle(color: Colors.blueGrey)),
                            Text('Lý do: ${item.reason}'),
                            if (item.adminComment != null && item.adminComment!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('Phản hồi: ${item.adminComment}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                            if (isPending) ...[
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                    icon: const Icon(Icons.close, size: 16),
                                    label: const Text('Từ chối'),
                                    onPressed: () => _handleReview(item, 'TuChoi'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                    icon: const Icon(Icons.check, size: 16),
                                    label: const Text('Duyệt đơn'),
                                    onPressed: () => _handleReview(item, 'DaDuyet'),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
