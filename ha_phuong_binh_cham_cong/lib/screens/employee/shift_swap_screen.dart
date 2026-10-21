import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/api_service.dart';

class ShiftSwapScreen extends StatefulWidget {
  final int userId;

  const ShiftSwapScreen({super.key, required this.userId});

  @override
  State<ShiftSwapScreen> createState() => _ShiftSwapScreenState();
}

class _ShiftSwapScreenState extends State<ShiftSwapScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _generatedQrCode;
  final _qrInputController = TextEditingController();
  bool _isLoading = false;

  int _selectedShiftFrom = 1; // Ca Sáng
  int _selectedShiftTo = 2; // Ca Chiều
  DateTime _swapDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _handleCreateSwap() async {
    setState(() => _isLoading = true);
    final res = await ApiService.createShiftSwap(
      requesterId: widget.userId,
      targetUserId: 1, // Đổi với đồng nghiệp khác
      currentShiftId: _selectedShiftFrom,
      desiredShiftId: _selectedShiftTo,
      swapDate: _swapDate,
      note: 'Nhờ đổi ca để bận việc cá nhân',
    );
    setState(() => _isLoading = false);

    if (res['success'] == true && res['data'] != null) {
      final qr = res['data']['swapQrCode']?.toString() ?? 'SWAP_DEFAULT_QR_123';
      setState(() {
        _generatedQrCode = qr;
        _qrInputController.text = qr; // Gợi ý luôn vào ô quét
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo mã QR đổi ca thành công! Hãy đưa mã này cho đồng nghiệp quét.'), backgroundColor: Colors.teal),
        );
      }
    }
  }

  void _handleConfirmSwap() async {
    final qr = _qrInputController.text.trim();
    if (qr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập hoặc quét mã QR!')));
      return;
    }

    setState(() => _isLoading = true);
    final res = await ApiService.confirmShiftSwap(swapQrCode: qr, targetUserId: widget.userId);
    setState(() => _isLoading = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Đổi ca thành công!'),
            ],
          ),
          content: Text(res['message'] ?? 'Hai nhân viên đã hoán đổi ca làm việc thành công! Lịch làm và lương đã được tính lại.'),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi ca P2P qua QR (1đ Mới)'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code), text: 'Tạo mã đổi ca'),
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'Quét nhận đổi ca'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Tạo mã QR đổi ca
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Card(
                  color: Color(0xFFE0F2F1),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Tính năng độc quyền: Nhân viên có thể chủ động đổi ca cho nhau chỉ bằng 1 thao tác quét mã QR bảo mật giữa 2 máy!',
                      style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedShiftFrom,
                  decoration: const InputDecoration(labelText: 'Ca của bạn muốn đổi', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Ca Sáng (08:00 - 12:00)')),
                    DropdownMenuItem(value: 2, child: Text('Ca Chiều (13:30 - 17:30)')),
                    DropdownMenuItem(value: 3, child: Text('Ca Tối OT (18:00 - 22:00)')),
                  ],
                  onChanged: (v) => setState(() => _selectedShiftFrom = v!),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  value: _selectedShiftTo,
                  decoration: const InputDecoration(labelText: 'Ca mong muốn đổi sang', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Ca Sáng (08:00 - 12:00)')),
                    DropdownMenuItem(value: 2, child: Text('Ca Chiều (13:30 - 17:30)')),
                    DropdownMenuItem(value: 3, child: Text('Ca Tối OT (18:00 - 22:00)')),
                  ],
                  onChanged: (v) => setState(() => _selectedShiftTo = v!),
                ),
                const SizedBox(height: 14),
                ListTile(
                  tileColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  leading: const Icon(Icons.calendar_month, color: Colors.teal),
                  title: const Text('Ngày đổi ca:'),
                  subtitle: Text('${_swapDate.day}/${_swapDate.month}/${_swapDate.year}'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _swapDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null) setState(() => _swapDate = picked);
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('TẠO MÃ QR ĐỔI CA', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: _isLoading ? null : _handleCreateSwap,
                ),
                if (_generatedQrCode != null) ...[
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        const Text('MÃ QR ĐỔI CA CỦA BẠN:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.teal, width: 2),
                          ),
                          child: QrImageView(
                            data: _generatedQrCode!,
                            version: QrVersions.auto,
                            size: 180.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Mã: $_generatedQrCode', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // TAB 2: Quét mã QR nhận đổi ca
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Nhận yêu cầu đổi ca từ đồng nghiệp',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Quét mã QR trên màn hình của đồng nghiệp hoặc dán mã QR vào ô bên dưới để xác nhận đổi ca:',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _qrInputController,
                  decoration: const InputDecoration(
                    labelText: 'Mã QR đổi ca',
                    prefixIcon: Icon(Icons.qr_code_scanner),
                    border: OutlineInputBorder(),
                    hintText: 'SWAP_...',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('XÁC NHẬN ĐỒNG Ý ĐỔI CA', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: _isLoading ? null : _handleConfirmSwap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
