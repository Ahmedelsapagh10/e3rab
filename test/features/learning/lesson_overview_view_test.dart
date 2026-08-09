import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/model/content_review_status.dart';
import 'package:new_strucuture/features/curriculum/data/model/lesson_model.dart';
import 'package:new_strucuture/features/learning/widgets/lesson_overview_view.dart';

void main() {
  testWidgets('lesson overview exposes six open phases and recommendation', (
    tester,
  ) async {
    final selectedPhases = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonOverviewView(
            lesson: _lesson,
            suggestedPhase: 1,
            onPhaseSelected: selectedPhases.add,
          ),
        ),
      ),
    );

    expect(find.text('١. افهم'), findsOneWidget);
    expect(find.text('٢. اكتشف'), findsOneWidget);
    expect(find.text('٣. شاهد الإعراب'), findsOneWidget);
    expect(find.text('٤. جرّب معي'), findsOneWidget);
    expect(find.text('٥. تدرّب وحدك'), findsOneWidget);
    expect(find.text('٦. اختبر إتقانك'), findsOneWidget);
    expect(find.text('الخطوة المقترحة'), findsOneWidget);
    expect(find.byType(InkWell), findsNWidgets(6));
    for (var index = 0; index < 6; index++) {
      await tester.ensureVisible(find.byType(InkWell).at(index));
      await tester.tap(find.byType(InkWell).at(index));
      await tester.pump();
    }
    expect(selectedPhases, [0, 1, 2, 3, 4, 5]);
  });

  testWidgets('lesson overview supports narrow RTL layout and large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 1000);
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
          body: LessonOverviewView(
            lesson: _lesson,
            suggestedPhase: 0,
            onPhaseSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('أقسام الكلمة'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
  sections: [],
  examples: [],
  exerciseIds: [],
  referenceIds: [],
  tags: [],
  estimatedMinutes: 10,
  contentVersion: '1.0.0',
  reviewStatus: ContentReviewStatus.sourceDocumented,
);
