class UserModel {
  final int id;
  final String username;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String role; // "Admin", "NhanVien", "QuanLy", "Khach"
  final String? department;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.department,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      role: json['role'] ?? 'NhanVien',
      department: json['department'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'department': department,
      'avatarUrl': avatarUrl,
    };
  }
}
