import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/model/content_review_status.dart';
import 'package:new_strucuture/features/curriculum/data/model/lesson_model.dart';
import 'package:new_strucuture/features/teacher/widgets/teacher_item_dialog.dart';

void main() {
  testWidgets('teacher item requires a title and selected lesson', (
    tester,
  ) async {
    TeacherItemDraft? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                result = await showTeacherItemDialog(
                  context,
                  title: 'مجموعة جديدة',
                  actionLabel: 'حفظ',
                  lessons: const [_lesson],
                );
              },
              child: const Text('فتح'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('فتح'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'حفظ'))
          .onPressed,
      isNull,
    );

    await tester.enterText(find.byType(TextField), 'فصل أ');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(result?.title, 'فصل أ');
    expect(result?.lessonIds, ['lesson']);
  });
}

const _lesson = LessonModel(
  id: 'lesson',
  unitId: 'unit',
  slug: 'lesson',
  title: 'درس',
  shortTitle: 'درس',
  stageIds: [],
  gradeIds: [],
  objectives: [],
  prerequisiteIds: [],
  sections: [],
  examples: [],
  exerciseIds: [],
  referenceIds: [],
  tags: [],
  estimatedMinutes: 5,
  contentVersion: '1.0.0',
  reviewStatus: ContentReviewStatus.aiAssistedDraft,
);
