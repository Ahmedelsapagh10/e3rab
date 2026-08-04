import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/model/content_review_status.dart';
import 'package:new_strucuture/features/curriculum/data/model/lesson_model.dart';
import 'package:new_strucuture/features/teacher/widgets/teacher_lesson_card.dart';

void main() {
  testWidgets('teacher card exposes planning metadata at large RTL text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              child: TeacherLessonCard(
                lesson: _lesson,
                prerequisites: const ['أقسام الكلمة'],
                hasPrivateNote: true,
                onPresent: () {},
                onNote: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(ExpansionTile));
    await tester.pumpAndSettle();

    expect(find.text('• هدف الدرس'), findsOneWidget);
    expect(find.text('• أقسام الكلمة'), findsOneWidget);
    expect(find.text('• لا تجعل أول كلمة مبتدأ دائمًا.'), findsOneWidget);
    expect(find.text('تعديل الملاحظة الخاصة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

const _lesson = LessonModel(
  id: 'lesson',
  unitId: 'unit',
  slug: 'lesson',
  title: 'المبتدأ والخبر',
  shortTitle: 'المبتدأ والخبر',
  stageIds: ['preparatory'],
  gradeIds: ['grade-7'],
  objectives: ['هدف الدرس'],
  prerequisiteIds: ['parts'],
  sections: [
    LessonSectionModel(
      id: 'mistake',
      type: 'misconceptions',
      title: 'خطأ شائع',
      body: 'لا تجعل أول كلمة مبتدأ دائمًا.',
      order: 1,
      referenceIds: [],
    ),
  ],
  examples: [],
  exerciseIds: [],
  referenceIds: [],
  tags: [],
  estimatedMinutes: 10,
  contentVersion: '1.0.0',
  reviewStatus: ContentReviewStatus.aiAssistedDraft,
);
