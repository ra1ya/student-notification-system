import 'package:flutter_test/flutter_test.dart';
import 'package:student_notification_system/main.dart';

void main() {
  testWidgets('student login screen renders', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('تسجيل دخول الطالب'), findsOneWidget);
    expect(find.text('رقم القيد'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
  });
}
