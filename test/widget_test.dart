import 'package:flutter_test/flutter_test.dart';
import 'package:unistudy/main.dart';

void main() {
  testWidgets('UNISTUDY app test', (WidgetTester tester) async {

    // تشغيل التطبيق
    await tester.pumpWidget(const UniStudyApp());

    // التأكد أن اسم التطبيق يظهر
    expect(find.text('UNISTUDY'), findsOneWidget);
  });
}