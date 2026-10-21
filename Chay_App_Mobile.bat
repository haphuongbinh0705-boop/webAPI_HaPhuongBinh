@echo off
chcp 65001 >nul
title Ứng Dụng Chấm Công - Hà Phương Bình
echo ========================================================
echo  HỆ THỐNG CHẤM CÔNG NHÂN VIÊN - HÀ PHƯƠNG BÌNH (2380600198)
echo ========================================================
echo.
echo Đang mở ứng dụng trên trình duyệt Chrome...
echo (Lưu ý: Bạn có thể nhấn F12 trên Chrome -> biểu tượng điện thoại để xem giao diện Mobile)
echo.
cd /d "%~dp0\ha_phuong_binh_cham_cong"
flutter run -d chrome
pause
