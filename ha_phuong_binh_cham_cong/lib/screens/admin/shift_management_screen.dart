import 'package:flutter/material.dart';
import '../../models/shift_model.dart';
import '../../services/api_service.dart';

class ShiftManagementScreen extends StatefulWidget {
  const ShiftManagementScreen({super.key});

  @override
  State<ShiftManagementScreen> createState() => _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends State<ShiftManagementScreen> {
  List<ShiftModel> _shifts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShifts();
  }

  void _loadShifts() async {
    setState(() => _isLoading = true);
    final list = await ApiService.getShifts();
    if (mounted) {
      setState(() {
        _shifts = list;
        _isLoading = false;
      });
    }
  }

  void _showAddShiftDialog() {
    final nameController = TextEditingController();
    final startController = TextEditingController(text: '08:00:00');
    final endController = TextEditingController(text: '17:00:00');
    final rateController = TextEditingController(text: '1.0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm ca làm việc mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên ca làm việc *', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: startController, decoration: const InputDecoration(labelText: 'Giờ bắt đầu (HH:mm:ss)', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: endController, decoration: const InputDecoration(labelText: 'Giờ kết thúc (HH:mm:ss)', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: rateController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hệ số lương (1.0 = chuẩn, 1.5 = OT)', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final newShift = ShiftModel(
                id: 0,
                shiftName: nameController.text.trim(),
                startTime: startController.text.trim(),
                endTime: endController.text.trim(),
                salaryRate: double.tryParse(rateController.text.trim()) ?? 1.0,
                description: 'Ca làm thêm mới',
              );
              await ApiService.createShift(newShift);
              _loadShifts();
            },
            child: const Text('Thêm ca'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Ca làm việc (CRUD)'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadShifts),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Thêm ca làm'),
        onPressed: _showAddShiftDialog,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _shifts.isEmpty
              ? const Center(child: Text('Chưa có ca làm việc nào.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _shifts.length,
                  itemBuilder: (context, index) {
                    final item = _shifts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple.shade100,
                          child: const Icon(Icons.alarm, color: Colors.purple),
                        ),
                        title: Text(item.shiftName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text('Thời gian: ${item.startTime} - ${item.endTime}\nHệ số lương: ${item.salaryRate}x'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await ApiService.deleteShift(item.id);
                            _loadShifts();
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
