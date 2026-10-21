class ShiftSwapModel {
  final int id;
  final int requesterId;
  final String? requesterName;
  final int targetUserId;
  final String? targetUserName;
  final int currentShiftId;
  final String? currentShiftName;
  final int desiredShiftId;
  final String? desiredShiftName;
  final String swapDate;
  final String swapQrCode;
  final String status; // "ChoXacNhan", "DaXacNhan", "TuChoi"
  final String? note;
  final String createdAt;

  ShiftSwapModel({
    required this.id,
    required this.requesterId,
    this.requesterName,
    required this.targetUserId,
    this.targetUserName,
    required this.currentShiftId,
    this.currentShiftName,
    required this.desiredShiftId,
    this.desiredShiftName,
    required this.swapDate,
    required this.swapQrCode,
    required this.status,
    this.note,
    required this.createdAt,
  });

  factory ShiftSwapModel.fromJson(Map<String, dynamic> json) {
    return ShiftSwapModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      requesterId: json['requesterId'] is int ? json['requesterId'] : int.tryParse(json['requesterId'].toString()) ?? 0,
      requesterName: json['requester'] != null ? json['requester']['fullName'] : null,
      targetUserId: json['targetUserId'] is int ? json['targetUserId'] : int.tryParse(json['targetUserId'].toString()) ?? 0,
      targetUserName: json['targetUser'] != null ? json['targetUser']['fullName'] : null,
      currentShiftId: json['currentShiftId'] is int ? json['currentShiftId'] : int.tryParse(json['currentShiftId'].toString()) ?? 1,
      currentShiftName: json['currentShift'] != null ? json['currentShift']['shiftName'] : null,
      desiredShiftId: json['desiredShiftId'] is int ? json['desiredShiftId'] : int.tryParse(json['desiredShiftId'].toString()) ?? 2,
      desiredShiftName: json['desiredShift'] != null ? json['desiredShift']['shiftName'] : null,
      swapDate: json['swapDate'] ?? '',
      swapQrCode: json['swapQrCode'] ?? '',
      status: json['status'] ?? 'ChoXacNhan',
      note: json['note'],
      createdAt: json['createdAt'] ?? '',
    );
  }
}
