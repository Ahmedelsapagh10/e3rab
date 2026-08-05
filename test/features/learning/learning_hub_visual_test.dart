import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/model/content_review_status.dart';
import 'package:new_strucuture/features/curriculum/data/model/lesson_model.dart';
import 'package:new_strucuture/features/learning/widgets/learning_hub_header.dart';
import 'package:new_strucuture/features/learning/widgets/lesson_card.dart';

void main() {
  testWidgets('learning hub cards support compact large-text RTL', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 1100);
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
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                LearningHubHeader(
                  onOpenReference: () {},
                  onOpenParsingLab: () {},
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 660,
                  child: LessonCard(lesson: _lesson, onOpen: _noOp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('مسارك في النحو واضح'), findsOneWidget);
    expect(find.text('موثّق بالمراجع'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _noOp() {}

const _lesson = LessonModel(
  id: 'parts-of-speech',
  unitId: 'foundation',
  slug: 'parts-of-speech',
  title: 'أقسام الكلمة في اللغة العربية',
  shortTitle: 'أقسام الكلمة',
  stageIds: ['foundation'],
  gradeIds: ['foundation'],
  objectives: ['تمييز الاسم والفعل والحرف باستخدام العلامات الواضحة'],
  prerequisiteIds: [],
  sections: [],
  examples: [],
  exerciseIds: ['one', 'two'],
  referenceIds: ['reference'],
  tags: ['الكلمة'],
  estimatedMinutes: 10,
  contentVersion: '1.0.0',
  reviewStatus: ContentReviewStatus.sourceDocumented,
);
