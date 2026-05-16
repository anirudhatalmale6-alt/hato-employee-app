import 'package:flutter_test/flutter_test.dart';
import 'package:hato_employee_app/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const HatoApp());
    await tester.pumpAndSettle();
    expect(find.text('Hato Employee'), findsAny);
  });
}
