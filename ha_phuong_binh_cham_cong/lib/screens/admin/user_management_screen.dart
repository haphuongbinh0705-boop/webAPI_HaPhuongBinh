import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<UserModel> _users = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  String? _selectedRoleFilter;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    setState(() => _isLoading = true);
    final list = await ApiService.getUsers(
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      role: _selectedRoleFilter,
    );
    if (mounted) {
      setState(() {
        _users = list;
        _isLoading = false;
      });
    }
  }

  // CREATE / EDIT User Dialog
  void _showUserDialog({UserModel? user}) {
    final isEdit = user != null;
    final usernameController = TextEditingController(text: user?.username ?? '');
    final passwordController = TextEditingController(text: isEdit ? '' : '123');
    final fullNameController = TextEditingController(text: user?.fullName ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    String role = user?.role ?? 'NhanVien';
    String department = user?.department ?? 'Công nghệ thông tin';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: Text(isEdit ? 'Sửa thông tin nhân viên' : 'Thêm nhân viên mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(labelText: 'Họ và tên *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                if (!isEdit) ...[
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: 'Tên đăng nhập *', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Mật khẩu *', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                ],
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Số điện thoại', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Vai trò (Role)', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'NhanVien', child: Text('Nhân viên')),
                    DropdownMenuItem(value: 'Admin', child: Text('Quản trị viên (Admin)')),
                    DropdownMenuItem(value: 'QuanLy', child: Text('Quản lý')),
                    DropdownMenuItem(value: 'Khach', child: Text('Khách hàng')),
                  ],
                  onChanged: (v) => setDlgState(() => role = v!),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: department,
                  decoration: const InputDecoration(labelText: 'Phòng ban', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Công nghệ thông tin', child: Text('Công nghệ thông tin')),
                    DropdownMenuItem(value: 'Phòng Nhân sự', child: Text('Phòng Nhân sự')),
                    DropdownMenuItem(value: 'Phòng Kế toán', child: Text('Phòng Kế toán')),
                    DropdownMenuItem(value: 'Phòng Marketing', child: Text('Phòng Marketing')),
                    DropdownMenuItem(value: 'Ban Giám Đốc', child: Text('Ban Giám Đốc')),
                  ],
                  onChanged: (v) => setDlgState(() => department = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                if (fullNameController.text.trim().isEmpty || emailController.text.trim().isEmpty) {
                  return;
                }
                Navigator.pop(ctx);
                if (isEdit) {
                  final updated = UserModel(
                    id: user.id,
                    username: user.username,
                    fullName: fullNameController.text.trim(),
                    email: emailController.text.trim(),
                    phoneNumber: phoneController.text.trim(),
                    role: role,
                    department: department,
                  );
                  await ApiService.updateUser(updated);
                } else {
                  final newUser = UserModel(
                    id: 0,
                    username: usernameController.text.trim(),
                    fullName: fullNameController.text.trim(),
                    email: emailController.text.trim(),
                    phoneNumber: phoneController.text.trim(),
                    role: role,
                    department: department,
                  );
                  await ApiService.createUser(newUser, passwordController.text.trim());
                }
                _loadUsers();
              },
              child: Text(isEdit ? 'Lưu thay đổi' : 'Thêm mới'),
            ),
          ],
        ),
      ),
    );
  }

  // DELETE confirmation
  void _confirmDelete(UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa nhân viên "${user.fullName}" (${user.username})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await ApiService.deleteUser(user.id);
              _loadUsers();
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Nhân viên (CRUD)'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsers),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: const Text('Thêm nhân viên'),
        onPressed: () => _showUserDialog(),
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm và lọc
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tên hoặc username...',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _loadUsers();
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _loadUsers(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedRoleFilter,
                  hint: const Text('Tất cả vai trò'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Tất cả')),
                    DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'NhanVien', child: Text('Nhân viên')),
                    DropdownMenuItem(value: 'QuanLy', child: Text('Quản lý')),
                  ],
                  onChanged: (v) {
                    setState(() => _selectedRoleFilter = v);
                    _loadUsers();
                  },
                ),
              ],
            ),
          ),

          // Danh sách nhân viên
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? const Center(child: Text('Không tìm thấy nhân viên nào!'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: user.role == 'Admin' ? Colors.red.shade100 : Colors.blue.shade100,
                                child: Text(
                                  user.fullName.isNotEmpty ? user.fullName[0] : 'U',
                                  style: TextStyle(
                                    color: user.role == 'Admin' ? Colors.red : Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${user.department ?? "CNTT"} • ${user.email}\nSĐT: ${user.phoneNumber ?? "N/A"}'),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showUserDialog(user: user),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _confirmDelete(user),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
