import 'package:flutter/material.dart';

class TranslationService {
  static final ValueNotifier<String> currentLang = ValueNotifier<String>('vi');

  static void setLanguage(String langCode) {
    currentLang.value = langCode;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'vi': {
      'app_title': 'Hệ Thống Chấm Công',
      'login_subtitle': 'Đăng nhập tài khoản & mã OTP để bắt đầu',
      'username': 'Tên đăng nhập',
      'password': 'Mật khẩu',
      'btn_login_otp': 'ĐĂNG NHẬP & NHẬN OTP',
      'face_id': 'Face ID',
      'fingerprint': 'Vân tay',
      'sample_accounts': 'Tài khoản mẫu để test nhanh phân quyền:',
      'no_account': 'Chưa có tài khoản?',
      'register_email': 'Đăng ký qua Email',
      'emp_dashboard': 'Dashboard Nhân viên',
      'salary_estimate': 'DỰ TOÁN LƯƠNG REAL-TIME',
      'choose_checkin_method': 'CHỌN HÌNH THỨC CHẤM CÔNG:',
      'demo_far_away': 'Demo: Giả lập đứng xa công ty (>300m)',
      'gps_checkin': 'GPS Check-in',
      'qr_checkin': 'Quét QR',
      'face_checkin': 'Chụp Face ID',
      'checkout': 'Check-Out',
      'emp_utilities': 'TIỆN ÍCH NHÂN VIÊN:',
      'history': 'Lịch sử chấm công',
      'leave_request': 'Đơn xin nghỉ phép (CRUD)',
      'shift_swap': 'Đổi ca làm việc P2P (QR)',
      'share_location': 'Chia sẻ vị trí công tác (GPS)',
      'share_location_sub': 'Gửi toạ độ thực tế & Google Maps cho Quản lý',
      'attach_proof': 'Chụp ảnh minh chứng (Giấy khám bệnh/Thẻ NV)',
    },
    'en': {
      'app_title': 'Attendance System',
      'login_subtitle': 'Login with Account & OTP to start',
      'username': 'Username',
      'password': 'Password',
      'btn_login_otp': 'LOGIN & GET OTP',
      'face_id': 'Face ID',
      'fingerprint': 'Fingerprint',
      'sample_accounts': 'Sample accounts for testing roles:',
      'no_account': 'Do not have an account?',
      'register_email': 'Register via Email',
      'emp_dashboard': 'Employee Dashboard',
      'salary_estimate': 'REAL-TIME SALARY ESTIMATE',
      'choose_checkin_method': 'CHOOSE ATTENDANCE METHOD:',
      'demo_far_away': 'Demo: Simulate outside office (>300m)',
      'gps_checkin': 'GPS Check-in',
      'qr_checkin': 'Scan QR',
      'face_checkin': 'Face ID Snap',
      'checkout': 'Check-Out',
      'emp_utilities': 'EMPLOYEE UTILITIES:',
      'history': 'Attendance History',
      'leave_request': 'Leave Request (CRUD)',
      'shift_swap': 'P2P Shift Swap (QR)',
      'share_location': 'Share Work Location (GPS)',
      'share_location_sub': 'Send live coordinates & Google Maps to Manager',
      'attach_proof': 'Capture Proof Photo (Medical/Badge)',
    },
    'ja': {
      'app_title': '勤怠管理システム',
      'login_subtitle': 'アカウントとOTPでログインして開始',
      'username': 'ユーザー名',
      'password': 'パスワード',
      'btn_login_otp': 'ログイン＆OTP取得',
      'face_id': '顔認証',
      'fingerprint': '指紋認証',
      'sample_accounts': 'テスト用サンプルアカウント:',
      'no_account': 'アカウントをお持ちでないですか？',
      'register_email': 'メールで登録',
      'emp_dashboard': '社員ダッシュボード',
      'salary_estimate': 'リアルタイム給与予測',
      'choose_checkin_method': '打刻方法を選択:',
      'demo_far_away': 'デモ: 会社範囲外シミュレーション (>300m)',
      'gps_checkin': 'GPS打刻',
      'qr_checkin': 'QR打刻',
      'face_checkin': '顔認証撮影',
      'checkout': '退勤打刻',
      'emp_utilities': '社員向け機能:',
      'history': '出退勤履歴',
      'leave_request': '有給・休暇申請 (CRUD)',
      'shift_swap': 'P2Pシフト交換 (QR)',
      'share_location': '現在地・出張位置を共有 (GPS)',
      'share_location_sub': 'Google Maps位置情報を管理者に送信',
      'attach_proof': '証明写真の撮影 (診断書・社員証)',
    },
  };

  static String tr(String key) {
    final lang = currentLang.value;
    return _localizedValues[lang]?[key] ?? _localizedValues['vi']?[key] ?? key;
  }
}
