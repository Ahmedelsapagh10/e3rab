import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/model/content_review_status.dart';
import 'package:new_strucuture/features/curriculum/data/model/grammar_coverage_model.dart';
import 'package:new_strucuture/features/curriculum/data/model/lesson_model.dart';
import 'package:new_strucuture/features/learning/cubit/learning_state.dart';
import 'package:new_strucuture/features/learning/widgets/curriculum_track_list.dart';

void main() {
  testWidgets('topic rows resolve lessons by stable topic id', (tester) async {
    const track = GrammarCoverageTrack(
      id: 'foundations',
      title: 'الأساسيات',
      order: 1,
      topics: ['الاسم والفعل والحرف وعلاماتها'],
      topicIds: ['foundations.parts-of-speech'],
    );
    const state = LearningState(
      status: LearningStatus.ready,
      coverageTracks: [track],
      lessons: [_lesson],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: CurriculumTrackList(state: state, query: ''),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.lock_clock_outlined), findsNothing);
    expect(find.text('قيد المراجعة النحوية'), findsNothing);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
  });
}

const _lesson = LessonModel(
  id: 'parts-of-speech',
  topicId: 'foundations.parts-of-speech',
  unitId: 'foundation',
  slug: 'parts-of-speech',
  title: 'عنوان مختلف تمامًا',
  shortTitle: 'أقسام الكلمة',
  stageIds: ['foundation'],
  gradeIds: ['general'],
  objectives: ['تمييز أقسام الكلمة'],
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
