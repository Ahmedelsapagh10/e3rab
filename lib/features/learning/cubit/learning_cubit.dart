import 'package:flutter_bloc/flutter_bloc.dart';

import '../../curriculum/data/curriculum_repository.dart';
import '../../curriculum/data/grammar_coverage_repository.dart';
import '../../curriculum/data/model/lesson_model.dart';
import '../../curriculum/data/model/exercise_model.dart';
import '../../curriculum/data/model/grammar_coverage_model.dart';
import '../../practice/domain/practice_queue_builder.dart';
import '../../progress/data/model/learning_progress_models.dart';
import '../../progress/data/model/learning_support_models.dart';
import '../../progress/data/progress_repository.dart';
import 'learning_state.dart';

class LearningCubit extends Cubit<LearningState> {
  LearningCubit(
    this._curriculum,
    this._progress,
    this.owner, {
    PracticeQueueBuilder queueBuilder = const PracticeQueueBuilder(),
    GrammarCoverageRepository? coverageRepository,
  }) : _queueBuilder = queueBuilder,
       _coverageRepository = coverageRepository,
       super(const LearningState());

  final CurriculumRepository _curriculum;
  final ProgressRepository _progress;
  final PracticeQueueBuilder _queueBuilder;
  final GrammarCoverageRepository? _coverageRepository;
  final LearningDataOwner owner;

  List<ExerciseModel> reviewQueue({int limit = 10}) {
    return _queueBuilder.reviewQueue(
      exercises: state.exercises.values.expand((items) => items).toList(),
      mastery: state.mastery,
      reviews: state.reviews,
      now: DateTime.now().toUtc(),
      limit: limit,
    );
  }

  List<ExerciseModel> cumulativeQueue({int limit = 15}) {
    return _queueBuilder.cumulativeQueue(
      exercisesByLesson: state.exercises,
      limit: limit,
    );
  }

  String skillLabel(String skillId) {
    final exercise = state.exercises.values
        .expand((items) => items)
        .where((item) => item.skillIds.contains(skillId))
        .firstOrNull;
    final lesson = state.lessons
        .where((item) => item.id == exercise?.lessonId)
        .firstOrNull;
    return lesson?.title ?? skillId;
  }

  Future<void> load() async {
    emit(state.copyWith(status: LearningStatus.loading));
    final lessonsResult = await _curriculum.getAllLessons();
    final lessons = lessonsResult.getOrElse(() => const []);
    if (lessonsResult.isLeft()) {
      emit(
        state.copyWith(
          status: LearningStatus.failure,
          message: 'تعذّر فتح المحتوى المحلي.',
        ),
      );
      return;
    }
    final exercises = <String, List<ExerciseModel>>{};
    for (final lesson in lessons) {
      final result = await _curriculum.getLessonExercises(lesson.id);
      exercises[lesson.id] = result.getOrElse(() => const []);
    }
    final progress = (await _progress.getLessonProgress(
      owner,
    )).getOrElse(() => const []);
    final bookmarks = (await _progress.getBookmarks(
      owner,
    )).getOrElse(() => const []);
    final notes = (await _progress.getNotes(owner)).getOrElse(() => const []);
    final mastery = (await _progress.getMastery(
      owner,
    )).getOrElse(() => const []);
    final reviews = (await _progress.getReviewItems(
      owner,
    )).getOrElse(() => const []);
    final references = (await _curriculum.getReferences()).getOrElse(
      () => const [],
    );
    final coverageTracks = await _loadCoverage();
    emit(
      LearningState(
        status: LearningStatus.ready,
        lessons: lessons,
        exercises: exercises,
        progress: progress,
        bookmarks: bookmarks,
        notes: notes,
        mastery: mastery,
        reviews: reviews,
        references: references,
        coverageTracks: coverageTracks,
      ),
    );
  }

  Future<List<GrammarCoverageTrack>> _loadCoverage() async {
    try {
      return await _coverageRepository?.getTracks() ?? const [];
    } catch (_) {
      return const [];
    }
  }

  Future<void> search(String query) async {
    final results = (await _curriculum.search(query)).getOrElse(() => const []);
    emit(state.copyWith(searchResults: results));
  }

  Future<void> toggleBookmark(LessonModel lesson) async {
    final existing = state.bookmarks
        .where((item) => item.targetId == lesson.id)
        .firstOrNull;
    final now = DateTime.now().toUtc();
    final bookmark = BookmarkModel(
      id: existing?.id ?? 'lesson-${lesson.id}',
      targetType: 'lesson',
      targetId: lesson.id,
      contentVersion: lesson.contentVersion,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      deletedAt: existing == null || existing.isDeleted ? null : now,
    );
    await _progress.saveBookmark(owner, bookmark);
    await load();
  }

  Future<void> markLessonStep(LessonModel lesson, String stepId) async {
    final existing = state.progressFor(lesson.id);
    final now = DateTime.now().toUtc();
    final completed = {...?existing?.completedSectionIds, stepId}.toList();
    await _progress.saveLessonProgress(
      owner,
      LessonProgressModel(
        lessonId: lesson.id,
        contentVersion: lesson.contentVersion,
        status: existing?.status == LessonProgressStatus.completed
            ? LessonProgressStatus.completed
            : LessonProgressStatus.inProgress,
        startedAt: existing?.startedAt ?? now,
        completedAt: existing?.completedAt,
        lastOpenedAt: now,
        completedSectionIds: completed,
        attemptCount: existing?.attemptCount ?? 0,
        bestScore: existing?.bestScore ?? 0,
        masteryScore: existing?.masteryScore ?? 0,
        updatedAt: now,
        schemaVersion: 2,
      ),
    );
    await load();
  }

  Future<void> saveNote(LessonModel lesson, String text) async {
    final existing = state.noteFor(lesson.id);
    final now = DateTime.now().toUtc();
    final note = LearningNoteModel(
      id: existing?.id ?? 'lesson-${lesson.id}',
      targetType: 'lesson',
      targetId: lesson.id,
      text: text.trim(),
      localVersion: (existing?.localVersion ?? 0) + 1,
      updatedAt: now,
      deletedAt: text.trim().isEmpty ? now : null,
      schemaVersion: 1,
    );
    await _progress.saveNote(owner, note);
    await load();
  }
}
