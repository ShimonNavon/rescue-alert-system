import 'package:flutter_test/flutter_test.dart';
import 'package:rescue_app/screens/rescue_alert_app.dart';

void main() {
  testWidgets('renders four bottom tabs and switches screens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RescueAlertApp());
    await tester.pumpAndSettle();

    expect(find.text('צוות תגובה פעיל'), findsOneWidget);
    expect(find.text('משתמשים'), findsNWidgets(2));
    expect(find.text('אירועים'), findsOneWidget);
    expect(find.text('PTT'), findsOneWidget);
    expect(find.text('קבוצות'), findsOneWidget);

    await tester.tap(find.text('אירועים'));
    await tester.pumpAndSettle();
    expect(find.text('עדכוני אירועים'), findsOneWidget);

    await tester.tap(find.text('PTT'));
    await tester.pumpAndSettle();
    expect(find.text('לחצן דיבור'), findsOneWidget);
    expect(find.text('ערוץ נבחר: מוקד אלפא'), findsOneWidget);

    await tester.tap(find.text('צוות רפואי בראבו'));
    await tester.pumpAndSettle();
    expect(find.text('ערוץ נבחר: צוות רפואי בראבו'), findsOneWidget);

    await tester.tap(find.text('קבוצות'));
    await tester.pumpAndSettle();
    expect(find.text('קבוצות תגובה'), findsOneWidget);
  });
}
