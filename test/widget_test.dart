import 'package:flutter_test/flutter_test.dart';
import 'package:student_notification_system/main.dart';

void main() {
  testWidgets('student login screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('تسجيل دخول كطالب'), findsOneWidget);
    expect(find.text('رقم القيد'), findsOneWidget);
  });
}
