class ShiftModel {
  final int id;
  final String shiftName;
  final String startTime;
  final String endTime;
  final double salaryRate;
  final String? description;

  ShiftModel({
    required this.id,
    required this.shiftName,
    required this.startTime,
    required this.endTime,
    required this.salaryRate,
    this.description,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      shiftName: json['shiftName'] ?? '',
      startTime: json['startTime'] ?? '08:00:00',
      endTime: json['endTime'] ?? '17:00:00',
      salaryRate: (json['salaryRate'] is num) ? (json['salaryRate'] as num).toDouble() : 1.0,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shiftName': shiftName,
      'startTime': startTime,
      'endTime': endTime,
      'salaryRate': salaryRate,
      'description': description,
    };
  }
}
