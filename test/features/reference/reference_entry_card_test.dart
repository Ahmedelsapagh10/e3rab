import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/data_source/local_curriculum_data_source.dart';
import 'package:new_strucuture/features/curriculum/data/local_curriculum_repository.dart';
import 'package:new_strucuture/features/curriculum/data/model/content_review_status.dart';
import 'package:new_strucuture/features/curriculum/data/model/lesson_model.dart';
import 'package:new_strucuture/features/learning/cubit/learning_cubit.dart';
import 'package:new_strucuture/features/learning/screens/lesson_screen.dart';
import 'package:new_strucuture/features/progress/data/data_source/local_learning_data_source.dart';
import 'package:new_strucuture/features/progress/data/local_first_progress_repository.dart';
import 'package:new_strucuture/features/progress/data/model/learning_progress_models.dart';
import 'package:new_strucuture/features/reference/data/model/grammar_reference_entry.dart';
import 'package:new_strucuture/features/reference/navigation/reference_lesson_navigator.dart';
import 'package:new_strucuture/features/reference/widgets/reference_entry_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
    expect(find.text('مسودة قيد المراجعة'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('full explanation opens from the reference route', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final local = LocalLearningDataSource(
      await SharedPreferences.getInstance(),
    );
    final curriculum = LocalCurriculumRepository(
      AssetCurriculumDataSource(bundle: rootBundle),
    );
    final progress = LocalFirstProgressRepository(local);
    final owner = LearningDataOwner.guest('reference-navigation');
    final learningCubit = LearningCubit(curriculum, progress, owner);
    addTearDown(learningCubit.close);
    addTearDown(local.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: _ReferenceRouteHarness(
          learningCubit: learningCubit,
          lesson: _entry.lesson,
        ),
      ),
    );

    await tester.tap(find.text('افتح الشرح الكامل'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(LessonScreen), findsOneWidget);
    expect(find.text('١. افهم'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _ReferenceRouteHarness extends StatelessWidget {
  const _ReferenceRouteHarness({
    required this.learningCubit,
    required this.lesson,
  });

  final LearningCubit learningCubit;
  final LessonModel lesson;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: FilledButton(
        onPressed: () => ReferenceLessonNavigator.open(
          context,
          learningCubit: learningCubit,
          lesson: lesson,
        ),
        child: const Text('افتح الشرح الكامل'),
      ),
    ),
  );
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
    reviewStatus: ContentReviewStatus.sourceDocumented,
  ),
);
