import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/progress/data/data_source/local_learning_data_source.dart';
import 'package:new_strucuture/features/progress/data/model/learning_progress_models.dart';
import 'package:new_strucuture/features/progress/data/model/learning_support_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists guest learning and isolates it from account data', () async {
    SharedPreferences.setMockInitialValues({});
    final source = LocalLearningDataSource(
      await SharedPreferences.getInstance(),
    );
    final guest = LearningDataOwner.guest('local-guest');
    final account = LearningDataOwner.account('account-1');
    final now = DateTime.utc(2026, 8, 4);

    await source.saveBookmark(
      guest,
      BookmarkModel(
        id: 'lesson-one',
        targetType: 'lesson',
        targetId: 'lesson-one',
        contentVersion: '1.0.0',
        createdAt: now,
        updatedAt: now,
      ),
    );

    expect(source.getBookmarks(guest), hasLength(1));
    expect(source.getBookmarks(account), isEmpty);
    expect(source.snapshot(guest).isEmpty, isFalse);
    await source.dispose();
  });

  test('upserts progress and keeps append attempt IDs stable', () async {
    SharedPreferences.setMockInitialValues({});
    final source = LocalLearningDataSource(
      await SharedPreferences.getInstance(),
    );
    final owner = LearningDataOwner.guest('guest');
    final now = DateTime.utc(2026, 8, 4);
    final progress = LessonProgressModel(
      lessonId: 'lesson-one',
      contentVersion: '1.0.0',
      status: LessonProgressStatus.completed,
      completedSectionIds: const ['rule'],
      attemptCount: 1,
      bestScore: 1,
      masteryScore: 1,
      updatedAt: now,
      schemaVersion: 1,
    );
    final attempt = ExerciseAttemptModel(
      attemptId: 'stable-attempt',
      exerciseId: 'exercise-one',
      lessonId: 'lesson-one',
      skillIds: const ['skill-one'],
      contentVersion: '1.0.0',
      selectedAnswer: 'option-one',
      isCorrect: true,
      scoreWeight: 1,
      hintUsed: false,
      attemptNumber: 1,
      durationMilliseconds: 100,
      clientCreatedAt: now,
      schemaVersion: 1,
    );

    await source.saveProgress(owner, progress);
    await source.appendAttempt(owner, attempt);
    await source.appendAttempt(owner, attempt);

    expect(source.getProgress(owner), [progress]);
    expect(source.getAttempts(owner), [attempt]);
    await source.dispose();
  });
}
