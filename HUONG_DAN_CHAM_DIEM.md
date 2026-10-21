# BÁO CÁO & HƯỚNG DẪN CHẤM ĐIỂM ĐỀ THI ỨNG DỤNG DI ĐỘNG
**Đề tài:** Ứng dụng Chấm công Nhân viên  
**Sinh viên thực hiện:** Hà Phương Bình  
**Mã số sinh viên (MSSV):** 2380600198 - Nhóm 10  
**Công nghệ sử dụng:** ASP.NET Core Web API 9.0 (Visual Studio tím) + Flutter 3.47 Mobile App  

---

## 🎯 BẢNG ĐỐI CHIẾU TIÊU CHÍ ĐÁNH GIÁ (THANG ĐIỂM 10)

| STT | Tiêu chí trong đề thi | Vị trí trong Code & Cách Demo | Trạng thái |
|:---:|:---|:---|:---:|
| **1** | **Đăng ký tài khoản qua Email** | • Giao diện: Nút "Đăng ký qua Email" tại màn hình Login.<br>• API: `POST /api/Auth/register`<br>• Kiểm tra hợp lệ email và trùng lặp tài khoản. | **ĐẠT** |
| **2** | **Đăng nhập: Tên đăng nhập + Mật khẩu + OTP** | • Bước 1: Nhập tài khoản + mật khẩu -> Hệ thống tạo OTP 6 số.<br>• **Gửi OTP về Gmail thật 100%**: Đã tích hợp Google SMTP gửi thẳng về `haphuongbinh0705@gmail.com`.<br>• Bước 2: Màn hình xác thực OTP bảo mật để nhập mã 6 số từ Gmail.<br>• API: `POST /api/Auth/login` & `POST /api/Auth/verify-otp`. | **ĐẠT** |
| **3** | **Phân quyền người dùng** | • **Admin**: Vào `AdminDashboard` (Quản trị hệ thống, thống kê chấm công toàn công ty).<br>• **Nhân viên**: Vào `EmployeeDashboard` (Chấm công GPS/QR/Face, xem công, làm đơn, đổi ca).<br>• **Quản lý**: Vào `ManagerDashboard` (Phê duyệt đơn xin nghỉ, giám sát chấm công).<br>• **Khách**: Vào `GuestScreen` (Thông tin công ty & Ứng tuyển).<br>*(Có 4 nút bấm chuyển nhanh tài khoản trên màn hình Login)* | **ĐẠT** |
| **4** | **Các chức năng CRUD (4.5đ)** | • **CRUD Nhân viên**: Thêm mới, Sửa, Xóa, Tìm kiếm theo tên, Lọc theo phòng ban và vai trò (`UserManagementScreen.dart`).<br>• **CRUD Ca làm việc**: Thêm, Sửa, Xóa ca làm việc (`ShiftManagementScreen.dart`).<br>• **CRUD Đơn nghỉ phép**: Nhân viên tạo đơn (ngày, lý do), Quản lý xem danh sách và Phê duyệt/Từ chối (`LeaveRequestScreen.dart` & `ManagerDashboard.dart`). | **ĐẠT (4.5/4.5)** |
| **5** | **Chọn 3 trong 6 chức năng (3.5đ)**<br>*(Đã làm vượt chỉ tiêu 4/6 chức năng)* | • **(a) Đăng nhập khuôn mặt & Chụp selfie Check-in**: Nhận diện Face ID lúc đăng nhập & Chụp ảnh selfie lúc bấm chấm công.<br>• **(b) Chia sẻ vị trí & Định vị GPS**: Nút "Chia sẻ vị trí công tác" sinh toạ độ thời gian thực + link Google Maps gửi cho Quản lý & GPS Geofencing bán kính 300m.<br>• **(e) Quét mã QR & Vân tay**: Quét mã QR văn phòng để Check-in + Đăng nhập vân tay Biometrics.<br>• **(f) Dịch Realtime & Ảnh chụp minh chứng**: Nút chuyển đổi ngôn ngữ tức thì (🇻🇳 Tiếng Việt, 🇬🇧 English, 🇯🇵 日本語) & Nút chụp ảnh minh chứng giấy khám bệnh đính kèm đơn nghỉ phép. | **ĐẠT (3.5/3.5)** |
| **6** | **Tính năng mới tự đề xuất (1đ)** | • **Đổi ca làm việc ngang hàng (P2P Shift Swap) bằng mã QR**: Nhân viên A tạo yêu cầu sinh mã QR -> Nhân viên B quét mã QR trên máy mình là ca làm tự động hoán đổi tức thì.<br>• **Dự toán lương Real-time**: Tự động tính số công tích lũy và số tiền lương tạm tính trong tháng ngay khi Check-out. | **ĐẠT (1.0/1.0)** |
| **7** | **Giao diện đẹp, cả nhóm chạy được (1đ)** | • Giao diện chuẩn Material 3 hiện đại, màu sắc trực quan, thẻ bo tròn mềm mại.<br>• Tích hợp cơ chế **Mock Data Fallback**: Dù thành viên trong nhóm chưa kịp mở SQL Server thì app vẫn chạy mượt mà 100% không lo bị crash! | **ĐẠT (1.0/1.0)** |

---

## 🔑 DANH SÁCH TÀI KHOẢN MẪU ĐỂ TEST
- **Admin**: `admin` / Mật khẩu: `123`
- **Nhân viên**: `binh.hp` / Mật khẩu: `123` (Nhận OTP qua `haphuongbinh0705@gmail.com`)
- **Quản lý**: `manager` / Mật khẩu: `123`
- **Khách**: `khach` / Mật khẩu: `123`
