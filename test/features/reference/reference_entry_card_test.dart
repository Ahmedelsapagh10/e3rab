import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/model/content_review_status.dart';
import 'package:new_strucuture/features/curriculum/data/model/lesson_model.dart';
import 'package:new_strucuture/features/reference/data/model/grammar_reference_entry.dart';
import 'package:new_strucuture/features/reference/widgets/reference_entry_card.dart';

void main() {
  testWidgets('comparison card remains readable in large-text RTL', (
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
              child: ReferenceEntryCard(
                entry: _entry,
                saved: false,
                onSaved: () {},
                onOpen: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Table), findsOneWidget);
    expect(find.text('موضع المقارنة'), findsOneWidget);
    expect(find.text('مسودة قيد المراجعة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

const _entry = GrammarReferenceEntry(
  id: 'comparison-lesson',
  type: GrammarReferenceType.comparison,
  title: 'قارن في المبتدأ والخبر',
  body: 'المبتدأ ليس دائمًا أول كلمة في الجملة.',
  keywords: 'المبتدأ الخبر',
  lesson: LessonModel(
    id: 'lesson',
    unitId: 'unit',
    slug: 'lesson',
    title: 'المبتدأ والخبر',
    shortTitle: 'المبتدأ والخبر',
    stageIds: ['preparatory'],
    gradeIds: ['grade-7'],
    objectives: ['تمييز المبتدأ والخبر'],
    prerequisiteIds: [],
    sections: [],
    examples: [],
    exerciseIds: [],
    referenceIds: [],
    tags: ['المبتدأ', 'الخبر'],
    estimatedMinutes: 10,
    contentVersion: '1.0.0',
    reviewStatus: ContentReviewStatus.aiAssistedDraft,
  ),
);
