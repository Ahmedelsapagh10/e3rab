import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'model/learning_progress_models.dart';
import 'model/learning_support_models.dart';

abstract class ProgressRepository {
  Stream<List<LessonProgressModel>> watchLessonProgress(
    LearningDataOwner owner,
  );

  Future<Either<Failure, Unit>> saveLessonProgress(
    LearningDataOwner owner,
    LessonProgressModel progress,
  );

  Future<Either<Failure, Unit>> appendExerciseAttempt(
    LearningDataOwner owner,
    ExerciseAttemptModel attempt,
  );

  Future<Either<Failure, List<ExerciseAttemptModel>>> getExerciseAttempts(
    LearningDataOwner owner,
  );

  Future<Either<Failure, List<LessonProgressModel>>> getLessonProgress(
    LearningDataOwner owner,
  );

  Future<Either<Failure, Unit>> saveBookmark(
    LearningDataOwner owner,
    BookmarkModel bookmark,
  );

  Future<Either<Failure, List<BookmarkModel>>> getBookmarks(
    LearningDataOwner owner,
  );

  Future<Either<Failure, Unit>> saveNote(
    LearningDataOwner owner,
    LearningNoteModel note,
  );

  Future<Either<Failure, List<LearningNoteModel>>> getNotes(
    LearningDataOwner owner,
  );

  Future<Either<Failure, List<SkillMasteryModel>>> getMastery(
    LearningDataOwner owner,
  );

  Future<Either<Failure, List<ReviewItemModel>>> getReviewItems(
    LearningDataOwner owner,
  );

  Future<Either<Failure, Unit>> resetProgress(LearningDataOwner owner);
}
