class AttendanceModel {
  final int id;
  final int userId;
  final String? userName;
  final String? department;
  final String? shiftName;
  final String date;
  final String? checkInTime;
  final String? checkOutTime;
  final double? latitude;
  final double? longitude;
  final String? locationAddress;
  final bool isLocationValid;
  final String method; // "GPS", "QR", "FACE", "FINGERPRINT"
  final String? checkInPhoto;
  final String status; // "DungGio", "DiMuon", "VeSom"
  final String? note;

  AttendanceModel({
    required this.id,
    required this.userId,
    this.userName,
    this.department,
    this.shiftName,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.latitude,
    this.longitude,
    this.locationAddress,
    this.isLocationValid = true,
    this.method = "GPS",
    this.checkInPhoto,
    this.status = "DungGio",
    this.note,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId'].toString()) ?? 0,
      userName: json['userName'],
      department: json['department'],
      shiftName: json['shiftName'],
      date: json['date'] ?? '',
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      locationAddress: json['locationAddress'],
      isLocationValid: json['isLocationValid'] ?? true,
      method: json['method'] ?? 'GPS',
      checkInPhoto: json['checkInPhoto'],
      status: json['status'] ?? 'DungGio',
      note: json['note'],
    );
  }
}
