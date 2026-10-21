import 'package:flutter/foundation.dart';

class ApiConfig {
  // Cấu hình URL mặc định:
  // - Nếu chạy trên Web hoặc Windows: http://localhost:5121
  // - Nếu chạy trên Máy ảo Android Emulator: http://10.0.2.2:5121
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:5121';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5121';
    } else {
      return 'http://localhost:5121';
    }
  }

  // Cho phép người dùng chỉnh sửa IP ngay trong màn hình cài đặt nếu muốn kết nối qua Wi-Fi
  static String baseUrl = defaultBaseUrl;

  // Tọa độ Trụ sở công ty (dùng cho tính năng Geofencing)
  static const double companyLat = 10.8018;
  static const double companyLng = 106.7118;
  static const double companyRadiusMeters = 300.0;
  static const String officeQrSecret = "HA_PHUONG_BINH_CHAM_CONG_OFFICE_2026";
}
