import 'package:flutter_test/flutter_test.dart';
import 'package:ha_phuong_binh_cham_cong/main.dart';

void main() {
  testWidgets('AttendanceApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AttendanceApp());
    expect(find.text('HỆ THỐNG CHẤM CÔNG'), findsOneWidget);
  });
}
