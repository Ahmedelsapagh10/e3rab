import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../domain/mastery_calculator.dart';
import 'data_source/cloud_learning_data_source.dart';
import 'data_source/local_learning_data_source.dart';
import 'model/learning_progress_models.dart';
import 'model/learning_support_models.dart';
import 'progress_repository.dart';

class LocalFirstProgressRepository implements ProgressRepository {
  LocalFirstProgressRepository(this._local, {CloudLearningDataSource? cloud})
    : _cloud = cloud;

  final LocalLearningDataSource _local;
  final CloudLearningDataSource? _cloud;

  @override
  Stream<List<LessonProgressModel>> watchLessonProgress(
    LearningDataOwner owner,
  ) => _local.watchProgress(owner);

  @override
  Future<Either<Failure, List<LessonProgressModel>>> getLessonProgress(
    LearningDataOwner owner,
  ) => _read(() => _local.getProgress(owner));

  @override
  Future<Either<Failure, Unit>> saveLessonProgress(
    LearningDataOwner owner,
    LessonProgressModel progress,
  ) async {
    try {
      await _local.saveProgress(owner, progress);
      await _forAccount(owner, (uid) => _cloud!.saveProgress(uid, progress));
      return const Right(unit);
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> appendExerciseAttempt(
    LearningDataOwner owner,
    ExerciseAttemptModel attempt,
  ) async {
    try {
      final attempts = _local.getAttempts(owner);
      if (attempts.any((item) => item.attemptId == attempt.attemptId)) {
        return const Right(unit);
      }
      await _local.appendAttempt(owner, attempt);
      await _forAccount(owner, (uid) => _cloud!.appendAttempt(uid, attempt));
      await _recalculate(owner, attempt.skillIds);
      return const Right(unit);
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<ExerciseAttemptModel>>> getExerciseAttempts(
    LearningDataOwner owner,
  ) => _read(() => _local.getAttempts(owner));

  @override
  Future<Either<Failure, Unit>> saveBookmark(
    LearningDataOwner owner,
    BookmarkModel bookmark,
  ) async {
    try {
      await _local.saveBookmark(owner, bookmark);
      await _forAccount(owner, (uid) => _cloud!.saveBookmark(uid, bookmark));
      return const Right(unit);
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<BookmarkModel>>> getBookmarks(
    LearningDataOwner owner,
  ) => _read(() => _local.getBookmarks(owner));

  @override
  Future<Either<Failure, Unit>> saveNote(
    LearningDataOwner owner,
    LearningNoteModel note,
  ) async {
    try {
      await _local.saveNote(owner, note);
      await _forAccount(owner, (uid) => _cloud!.saveNote(uid, note));
      return const Right(unit);
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<LearningNoteModel>>> getNotes(
    LearningDataOwner owner,
  ) => _read(() => _local.getNotes(owner));

  @override
  Future<Either<Failure, List<SkillMasteryModel>>> getMastery(
    LearningDataOwner owner,
  ) => _read(() => _local.getMastery(owner));

  @override
  Future<Either<Failure, List<ReviewItemModel>>> getReviewItems(
    LearningDataOwner owner,
  ) => _read(() => _local.getReviews(owner));

  @override
  Future<Either<Failure, Unit>> resetProgress(LearningDataOwner owner) async {
    try {
      if (owner.type == LearningDataOwnerType.account) {
        final cloud = _cloud;
        if (cloud == null) return Left(ServerFailure());
        await cloud.resetProgress(owner.id);
      }
      await _local.resetProgress(owner);
      return const Right(unit);
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  Future<void> _recalculate(
    LearningDataOwner owner,
    List<String> skillIds,
  ) async {
    final attempts = _local.getAttempts(owner);
    final previous = {
      for (final item in _local.getMastery(owner)) item.skillId: item,
    };
    final now = DateTime.now().toUtc();
    for (final skillId in skillIds) {
      final mastery = MasteryCalculator.calculate(
        skillId: skillId,
        attempts: attempts,
        now: now,
        previous: previous[skillId],
      );
      final review = ReviewItemModel(
        id: 'skill-$skillId',
        targetType: 'skill',
        targetId: skillId,
        dueAt: mastery.nextReviewAt,
        intervalLevel: MasteryCalculator.reviewIntervalLevel(mastery),
        lastResult: attempts.last.isCorrect ? 'correct' : 'incorrect',
        updatedAt: now,
        algorithmVersion: 1,
      );
      await _local.saveMastery(owner, mastery);
      await _local.saveReview(owner, review);
      await _forAccount(owner, (uid) => _cloud!.saveMastery(uid, mastery));
      await _forAccount(owner, (uid) => _cloud!.saveReview(uid, review));
    }
  }

  Future<void> _forAccount(
    LearningDataOwner owner,
    Future<void> Function(String uid) write,
  ) async {
    if (owner.type == LearningDataOwnerType.account && _cloud != null) {
      try {
        await write(owner.id);
      } catch (_) {
        // Local data remains authoritative and retryable after connectivity returns.
      }
    }
  }

  Future<Either<Failure, T>> _read<T>(T Function() read) async {
    try {
      return Right(read());
    } catch (_) {
      return Left(CacheFailure());
    }
  }
}
