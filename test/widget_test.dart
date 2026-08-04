import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/config/themes/app_theme.dart';
import 'package:new_strucuture/core/widgets/custom_button.dart';
import 'package:new_strucuture/features/login/screens/login_screen.dart';

void main() {
  testWidgets('login screen builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const LoginScreen()),
    );

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('custom button keeps long Arabic text visible', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(280, 180);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: CustomButton(
              title:
                  '\u062a\u0633\u062c\u064a\u0644 \u0627\u0644\u062f\u062e\u0648\u0644 \u0625\u0644\u0649 \u0627\u0644\u062d\u0633\u0627\u0628',
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(CustomButton)).height,
      greaterThanOrEqualTo(52),
    );
    expect(
      find.text(
        '\u062a\u0633\u062c\u064a\u0644 \u0627\u0644\u062f\u062e\u0648\u0644 \u0625\u0644\u0649 \u0627\u0644\u062d\u0633\u0627\u0628',
      ),
      findsOneWidget,
    );
  });
}
