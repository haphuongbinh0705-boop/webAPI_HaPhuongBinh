class LeaveRequestModel {
  final int id;
  final int userId;
  final String? userName;
  final String leaveType;
  final String fromDate;
  final String toDate;
  final String reason;
  final String status; // "ChoDuyet", "DaDuyet", "TuChoi"
  final String? adminComment;
  final String createdAt;

  LeaveRequestModel({
    required this.id,
    required this.userId,
    this.userName,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    required this.status,
    this.adminComment,
    required this.createdAt,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId'].toString()) ?? 0,
      userName: json['userName'],
      leaveType: json['leaveType'] ?? 'Nghỉ phép năm',
      fromDate: json['fromDate'] ?? '',
      toDate: json['toDate'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'ChoDuyet',
      adminComment: json['adminComment'],
      createdAt: json['createdAt'] ?? '',
    );
  }
}
