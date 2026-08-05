import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/model/content_review_status.dart';
import 'package:new_strucuture/features/curriculum/data/model/lesson_model.dart';
import 'package:new_strucuture/features/learning/widgets/lesson_content_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('lesson remains usable in RTL with large text', (tester) async {
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.8)),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        ),
        home: Scaffold(
          body: LessonContentView(
            lesson: _lesson,
            references: const [],
            onReference: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('أقسام الكلمة'), findsOneWidget);
    expect(find.text('بعد هذا الدرس ستستطيع:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lesson advances one clear step and reports saved progress', (
    tester,
  ) async {
    String? completedStep;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonContentView(
            lesson: _lesson,
            references: const [],
            onReference: (_) {},
            onStepCompleted: (value) => completedStep = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('فهمت، تابع'));
    await tester.pumpAndSettle();

    expect(completedStep, 'parts-of-speech-journey-introduction');
    expect(find.text('القاعدة ببساطة'), findsOneWidget);
    expect(find.text('الخطوة 2 من 5'), findsOneWidget);
  });
}

const _lesson = LessonModel(
  id: 'parts-of-speech',
  unitId: 'foundation',
  slug: 'parts-of-speech',
  title: 'أقسام الكلمة',
  shortTitle: 'أقسام الكلمة',
  stageIds: ['foundation'],
  gradeIds: ['foundation'],
  objectives: ['تمييز الاسم والفعل والحرف.'],
  prerequisiteIds: [],
  sections: [
    LessonSectionModel(
      id: 'rule',
      type: 'rule',
      title: 'القاعدة',
      body: 'الكلمة اسم أو فعل أو حرف، ونحدد نوعها من معناها وعلاماتها.',
      order: 1,
      referenceIds: [],
    ),
  ],
  examples: [],
  exerciseIds: [],
  referenceIds: [],
  tags: ['الكلمة'],
  estimatedMinutes: 10,
  contentVersion: '1.0.0',
  reviewStatus: ContentReviewStatus.aiAssistedDraft,
);
