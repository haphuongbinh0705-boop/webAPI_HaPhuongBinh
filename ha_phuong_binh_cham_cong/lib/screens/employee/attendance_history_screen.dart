import 'package:flutter/material.dart';
import '../../models/attendance_model.dart';
import '../../services/api_service.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final int userId;

  const AttendanceHistoryScreen({super.key, required this.userId});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  List<AttendanceModel> _list = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getAttendanceHistory(widget.userId);
    if (mounted) {
      setState(() {
        _list = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử chấm công'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadHistory),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? const Center(child: Text('Chưa có dữ liệu chấm công trong tháng!'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _list.length,
                  itemBuilder: (context, index) {
                    final item = _list[index];
                    final isOntime = item.status == 'DungGio';
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
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                                    const SizedBox(width: 6),
                                    Text(item.date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isOntime ? Colors.green.shade100 : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isOntime ? 'Đúng giờ' : 'Đi muộn',
                                    style: TextStyle(
                                      color: isOntime ? Colors.green.shade800 : Colors.red.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text('Check-In', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text(item.checkInTime ?? '--:--', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('Check-Out', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text(item.checkOutTime ?? '--:--', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('Phương thức', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Chip(
                                      label: Text(item.method, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (item.locationAddress != null) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(
                                    item.isLocationValid ? Icons.check_circle : Icons.warning,
                                    size: 16,
                                    color: item.isLocationValid ? Colors.green : Colors.orange,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      item.locationAddress!,
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                    ),
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
