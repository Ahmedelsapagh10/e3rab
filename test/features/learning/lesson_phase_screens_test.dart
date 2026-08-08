import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/model/content_review_status.dart';
import 'package:new_strucuture/features/curriculum/data/model/lesson_model.dart';
import 'package:new_strucuture/features/learning/screens/lesson_examples_screen.dart';
import 'package:new_strucuture/features/learning/screens/lesson_explanation_screen.dart';

void main() {
  testWidgets('explanation is a focused readable phase', (tester) async {
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: LessonExplanationScreen(
          lesson: _lesson,
          onCompleted: () async => completed = true,
        ),
      ),
    );

    expect(find.text('الشرح'), findsOneWidget);
    expect(find.text('ماذا ستتعلم؟'), findsOneWidget);
    expect(find.text('اختر إجابة'), findsNothing);
    await tester.tap(find.text('فهمت الشرح'));
    await tester.pumpAndSettle();
    expect(completed, isTrue);
  });

  testWidgets('examples phase lists three separate tappable examples', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LessonExamplesScreen(lesson: _lesson, onCompleted: () async {}),
      ),
    );

    expect(find.byType(ListTile), findsNWidgets(3));
    await tester.tap(find.text('العِلْمُ نُورٌ'));
    await tester.pumpAndSettle();
    expect(find.text('شرح المثال'), findsOneWidget);
    expect(find.text('السبب: اسم مفرد'), findsOneWidget);
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
      body: 'الكلمة اسم أو فعل أو حرف.',
      order: 1,
      referenceIds: [],
    ),
  ],
  examples: [
    _example,
    GrammarExampleModel(
      id: 'two',
      sentence: 'يكتب الطالب',
      fullyDiacritizedSentence: 'يَكْتُبُ الطَّالِبُ',
      parsedWords: [],
      explanation: 'مثال فعل.',
      referenceIds: [],
    ),
    GrammarExampleModel(
      id: 'three',
      sentence: 'في المدرسة',
      fullyDiacritizedSentence: 'فِي المَدْرَسَةِ',
      parsedWords: [],
      explanation: 'مثال حرف.',
      referenceIds: [],
    ),
  ],
  exerciseIds: [],
  referenceIds: [],
  tags: [],
  estimatedMinutes: 10,
  contentVersion: '1.0.0',
  reviewStatus: ContentReviewStatus.sourceDocumented,
);

const _example = GrammarExampleModel(
  id: 'one',
  sentence: 'العلم نور',
  fullyDiacritizedSentence: 'العِلْمُ نُورٌ',
  parsedWords: [
    ParsedWordModel(
      word: 'العلم',
      normalizedWord: 'العلم',
      wordType: 'اسم',
      grammaticalRole: 'مبتدأ',
      grammaticalState: 'مرفوع',
      grammaticalSign: 'الضمة',
      signReason: 'اسم مفرد',
      explanation: 'يقبل أل.',
      startIndex: 0,
      endIndex: 5,
    ),
  ],
  explanation: 'العلم اسم.',
  referenceIds: [],
);
