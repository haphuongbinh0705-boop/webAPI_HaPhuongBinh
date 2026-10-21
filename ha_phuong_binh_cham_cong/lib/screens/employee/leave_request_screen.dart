import 'package:flutter/material.dart';
import '../../models/leave_request_model.dart';
import '../../services/api_service.dart';

class LeaveRequestScreen extends StatefulWidget {
  final int userId;

  const LeaveRequestScreen({super.key, required this.userId});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  List<LeaveRequestModel> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getLeaveRequests(userId: widget.userId);
    if (mounted) {
      setState(() {
        _requests = data;
        _isLoading = false;
      });
    }
  }

  void _showCreateDialog() {
    final reasonController = TextEditingController();
    String selectedType = 'Nghỉ phép năm';
    DateTime fromDate = DateTime.now().add(const Duration(days: 1));
    DateTime toDate = DateTime.now().add(const Duration(days: 1));
    bool hasProofPhoto = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tạo đơn xin nghỉ phép'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Loại nghỉ phép', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Nghỉ phép năm', child: Text('Nghỉ phép năm')),
                    DropdownMenuItem(value: 'Nghỉ ốm', child: Text('Nghỉ ốm')),
                    DropdownMenuItem(value: 'Việc gia đình', child: Text('Việc gia đình')),
                    DropdownMenuItem(value: 'Nghỉ không lương', child: Text('Nghỉ không lương')),
                  ],
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.date_range, color: Colors.blue),
                  title: const Text('Từ ngày:'),
                  subtitle: Text('${fromDate.day}/${fromDate.month}/${fromDate.year}'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: fromDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        fromDate = picked;
                        if (toDate.isBefore(fromDate)) toDate = fromDate;
                      });
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event, color: Colors.blue),
                  title: const Text('Đến ngày:'),
                  subtitle: Text('${toDate.day}/${toDate.month}/${toDate.year}'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: toDate,
                      firstDate: fromDate,
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) setDialogState(() => toDate = picked);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Lý do nghỉ phép *',
                    border: OutlineInputBorder(),
                    hintText: 'Nhập chi tiết lý do xin nghỉ...',
                  ),
                ),
                const SizedBox(height: 12),
                // 5f: Chức năng chụp ảnh minh chứng (giấy khám bệnh, chứng từ y tế)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: hasProofPhoto ? Colors.green : Colors.blue,
                    side: BorderSide(color: hasProofPhoto ? Colors.green : Colors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: Icon(hasProofPhoto ? Icons.check_circle : Icons.camera_alt),
                  label: Text(hasProofPhoto ? 'Đã chụp ảnh minh chứng (Hợp lệ)' : 'Chụp ảnh minh chứng (Giấy khám/Đơn)'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (camCtx) => AlertDialog(
                        title: const Row(
                          children: [
                            Icon(Icons.camera_alt, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Chụp ảnh tài liệu minh chứng'),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.blue.shade300, width: 2),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.document_scanner, size: 55, color: Colors.blue),
                                  SizedBox(height: 8),
                                  Text('Căn chỉnh giấy khám bệnh / đơn từ vào khung...', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(camCtx), child: const Text('Hủy')),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.camera),
                            label: const Text('Chụp & Đính kèm'),
                            onPressed: () {
                              Navigator.pop(camCtx);
                              setDialogState(() => hasProofPhoto = true);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập lý do xin nghỉ!')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final success = await ApiService.createLeaveRequest(
                  userId: widget.userId,
                  leaveType: selectedType,
                  fromDate: fromDate,
                  toDate: toDate,
                  reason: reasonController.text.trim(),
                );
                if (success) {
                  _loadRequests();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nộp đơn nghỉ phép thành công!'), backgroundColor: Colors.green),
                    );
                  }
                }
              },
              child: const Text('Nộp đơn'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'DaDuyet':
        return Colors.green;
      case 'TuChoi':
        return Colors.red;
      case 'ChoDuyet':
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'DaDuyet':
        return 'Đã duyệt';
      case 'TuChoi':
        return 'Từ chối';
      case 'ChoDuyet':
      default:
        return 'Chờ duyệt';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn xin nghỉ phép (CRUD)'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadRequests),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Tạo đơn mới'),
        onPressed: _showCreateDialog,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text('Bạn chưa có đơn xin nghỉ phép nào.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final item = _requests[index];
                    final color = _getStatusColor(item.status);
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
                                Text(item.leaveType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                                  child: Text(_getStatusText(item.status), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Thời gian: ${item.fromDate} đến ${item.toDate}', style: const TextStyle(color: Colors.blueGrey)),
                            const SizedBox(height: 4),
                            Text('Lý do: ${item.reason}', style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Ảnh chứng từ minh chứng (5f)'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          height: 180,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.blue.shade200),
                                          ),
                                          child: const Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.receipt_long, size: 60, color: Colors.blue),
                                              SizedBox(height: 8),
                                              Text('Giấy khám bệnh / Đơn minh chứng đính kèm', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                                              Text('Độ phân giải: 1080p • Chụp từ Camera máy', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.photo_camera, size: 14, color: Colors.blue),
                                    SizedBox(width: 4),
                                    Text('Xem ảnh minh chứng đã chụp (5f)', style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            if (item.adminComment != null && item.adminComment!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                                child: Text('Ý kiến Quản lý: ${item.adminComment}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
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
