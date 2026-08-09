import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/config/themes/light_theme.dart';
import 'package:new_strucuture/core/design_system/e3rab_design_tokens.dart';
import 'package:new_strucuture/features/curriculum/data/model/content_review_status.dart';
import 'package:new_strucuture/features/curriculum/data/model/lesson_model.dart';
import 'package:new_strucuture/features/learning/screens/lesson_examples_screen.dart';
import 'package:new_strucuture/features/learning/screens/lesson_explanation_screen.dart';
import 'package:new_strucuture/features/learning/screens/guided_parsing_screen.dart';

void main() {
  testWidgets('explanation is a focused readable phase', (tester) async {
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: LightTheme.theme,
        home: LessonExplanationScreen(
          lesson: _lesson,
          onCompleted: () async => completed = true,
        ),
      ),
    );

    expect(find.text('الشرح'), findsOneWidget);
    expect(find.text('ماذا ستتعلم؟'), findsOneWidget);
    final objectivesCard = tester.widget<Card>(find.byType(Card));
    final objectivesTitle = tester.widget<Text>(find.text('ماذا ستتعلم؟'));
    expect(objectivesCard.color, E3rabBrandColors.primaryContainer);
    expect(objectivesTitle.style?.color, E3rabBrandColors.heading);
    expect(objectivesTitle.style?.fontWeight, FontWeight.w600);
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

  testWidgets('guided parsing reveals the seven decisions progressively', (
    tester,
  ) async {
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: GuidedParsingScreen(
          lesson: _lesson,
          onCompleted: () async => completed = true,
        ),
      ),
    );

    expect(find.text('ما نوع هذه الكلمة؟'), findsOneWidget);
    expect(find.text('اسم'), findsNothing);
    for (var decision = 0; decision < 7; decision++) {
      await tester.tap(find.text('اكشف الإجابة'));
      await tester.pump();
      if (decision < 6) {
        await tester.tap(find.text('القرار التالي'));
        await tester.pump();
      }
    }
    expect(find.text('أكملت الإعراب الموجّه'), findsOneWidget);
    expect(completed, isFalse);
    await tester.tap(find.text('أكملت الإعراب الموجّه'));
    await tester.pumpAndSettle();
    expect(completed, isTrue);
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
