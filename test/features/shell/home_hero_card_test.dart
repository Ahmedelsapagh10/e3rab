import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/model/content_review_status.dart';
import 'package:new_strucuture/features/curriculum/data/model/lesson_model.dart';
import 'package:new_strucuture/features/learning/cubit/learning_state.dart';
import 'package:new_strucuture/features/shell/widgets/home_hero_card.dart';
import 'package:new_strucuture/features/progress/data/model/learning_progress_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final width in [360.0, 1024.0]) {
    testWidgets('home hero remains clear at ${width.round()}px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            ),
          ),
          home: const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: HomeHeroCard(state: _state),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('خطوة صغيرة اليوم،\nفرق كبير غدًا'), findsOneWidget);
      expect(find.text('ابدأ درس اليوم'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('home safely explains when no lessons are available', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HomeHeroCard(state: LearningState())),
      ),
    );

    expect(find.text('المحتوى قيد التجهيز'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home explains completed course without reopening first lesson', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HomeHeroCard(state: _completedState)),
      ),
    );

    expect(find.text('أكملت المسار المتاح'), findsOneWidget);
    expect(find.text('متابعة الدرس'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

const _state = LearningState(lessons: [_lesson]);

final _completedState = LearningState(
  lessons: const [_lesson],
  progress: [
    LessonProgressModel(
      lessonId: _lesson.id,
      contentVersion: _lesson.contentVersion,
      status: LessonProgressStatus.completed,
      completedSectionIds: const [],
      attemptCount: 5,
      bestScore: 1,
      masteryScore: 1,
      updatedAt: DateTime.utc(2026),
      schemaVersion: 3,
      masteryStatus: LessonMasteryStatus.mastered,
    ),
  ],
);

const _lesson = LessonModel(
  id: 'parts-of-speech',
  unitId: 'foundation',
  slug: 'parts-of-speech',
  title: 'أقسام الكلمة',
  shortTitle: 'أقسام الكلمة',
  stageIds: ['foundation'],
  gradeIds: ['foundation'],
  objectives: ['تمييز الاسم والفعل والحرف'],
  prerequisiteIds: [],
  sections: [],
  examples: [],
  exerciseIds: [],
  referenceIds: [],
  tags: ['الكلمة'],
  estimatedMinutes: 10,
  contentVersion: '1.0.0',
  reviewStatus: ContentReviewStatus.sourceDocumented,
);
