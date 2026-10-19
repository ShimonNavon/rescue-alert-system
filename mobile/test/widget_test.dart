import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rescue_app/domain/models/auth_user.dart';
import 'package:rescue_app/domain/services/auth_service.dart';
import 'package:rescue_app/presentation/router/app_router.dart';
import 'package:rescue_app/screens/rescue_alert_app.dart';

void main() {
  testWidgets('renders four bottom tabs and switches screens', (
    WidgetTester tester,
  ) async {
    AuthService.instance.debugSetUser(
      const AuthUser(
        id: 1,
        username: 'tester',
        email: 'tester@example.com',
        name: 'Tester',
        role: 'admin',
        isStaff: true,
      ),
    );
    appRouter.go(AppRoutePaths.home);
    await tester.pumpWidget(const RescueAlertApp());
    await tester.pumpAndSettle();

    expect(find.text('צוות תגובה פעיל'), findsOneWidget);
    expect(find.text('משתמשים'), findsWidgets);
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

    final groupAvatars = find.byType(CircleAvatar);
    expect(groupAvatars, findsNWidgets(3));
    await tester.tap(groupAvatars.at(1));
    await tester.pumpAndSettle();
    expect(find.text('ערוץ נבחר: צוות רפואי בראבו'), findsOneWidget);

    await tester.tap(find.text('היסטוריה'));
    await tester.pumpAndSettle();
    expect(find.text('לאחרונה'), findsOneWidget);
  });
}
