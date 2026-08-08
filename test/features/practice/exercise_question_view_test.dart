import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/model/content_review_status.dart';
import 'package:new_strucuture/features/curriculum/data/model/exercise_model.dart';
import 'package:new_strucuture/features/learning/cubit/exercise_state.dart';
import 'package:new_strucuture/features/learning/widgets/exercise_question_view.dart';
import 'package:new_strucuture/features/practice/domain/practice_session_config.dart';

void main() {
  testWidgets('classification renderer supports large RTL text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const state = ExerciseState(
      exercises: [_exercise],
      config: PracticeSessionConfig.review(),
    );

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
        home: Scaffold(body: _view(state)),
      ),
    );

    expect(find.text('اختر التصنيف الأدق، ثم تحقق من الدليل.'), findsOneWidget);
    expect(find.text('اكشف الإجابة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('timed alternative exposes remaining time and hides reveal', (
    tester,
  ) async {
    const state = ExerciseState(
      exercises: [_exercise],
      config: PracticeSessionConfig.timed(durationSeconds: 30),
      remainingSeconds: 30,
    );

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: _view(state))));

    expect(find.text('00:30'), findsOneWidget);
    expect(find.text('اكشف الإجابة'), findsNothing);
  });

  testWidgets('lesson exam hides help and immediate correctness feedback', (
    tester,
  ) async {
    const state = ExerciseState(
      exercises: [_exercise],
      config: PracticeSessionConfig.lessonExam(),
      selectedOptionId: 'correct',
      submitted: true,
      correctCount: 1,
    );

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: _view(state))));

    expect(find.text('تلميح'), findsNothing);
    expect(find.text('اكشف الإجابة'), findsNothing);
    expect(find.text('إجابة صحيحة'), findsNothing);
    expect(find.text('إنهاء الاختبار'), findsOneWidget);
  });
}

Widget _view(ExerciseState state) {
  return ExerciseQuestionView(
    state: state,
    onSelect: (_) {},
    onHint: () {},
    onReveal: () {},
    onSubmit: () {},
    onNext: () {},
  );
}

const _exercise = ExerciseModel(
  id: 'classification',
  lessonId: 'lesson',
  type: ExerciseType.classification,
  prompt: 'صنّف كلمة «العلم».',
  skillIds: ['parts-of-speech'],
  stageIds: ['foundation'],
  gradeIds: ['foundation'],
  difficulty: 1,
  options: [
    ExerciseOptionModel(id: 'correct', text: 'اسم', feedback: 'تقبل أل.'),
    ExerciseOptionModel(id: 'wrong', text: 'فعل', feedback: 'لا تدل على زمن.'),
  ],
  correctAnswerIds: ['correct'],
  explanation: 'العلم اسم لقبوله أل.',
  hint: 'جرّب إدخال أل.',
  referenceIds: [],
  contentVersion: '1.0.0',
  reviewStatus: ContentReviewStatus.aiAssistedDraft,
  schemaVersion: 1,
);
