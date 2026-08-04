import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/teacher/domain/teacher_presentation_builder.dart';
import 'package:new_strucuture/features/teacher/screens/teacher_presentation_screen.dart';

void main() {
  testWidgets('classroom presentation supports keyboard navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: TeacherPresentationScreen(
            slides: [
              TeacherSlideModel(title: 'الأولى', lines: ['تمهيد']),
              TeacherSlideModel(title: 'الثانية', lines: ['قاعدة']),
            ],
          ),
        ),
      ),
    );

    expect(find.text('الأولى'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();

    expect(find.text('الثانية'), findsOneWidget);
    expect(find.text('عرض صفي • 2/2'), findsOneWidget);
  });
}
