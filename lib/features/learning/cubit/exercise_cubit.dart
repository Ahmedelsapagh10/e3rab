import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../curriculum/data/model/exercise_model.dart';
import '../../curriculum/data/model/lesson_model.dart';
import '../../practice/domain/exercise_attempt_factory.dart';
import '../../practice/domain/lesson_completion_service.dart';
import '../../practice/domain/practice_session_config.dart';
import '../../progress/data/model/learning_progress_models.dart';
import '../../progress/data/progress_repository.dart';
import 'exercise_state.dart';

class ExerciseCubit extends Cubit<ExerciseState> {
  ExerciseCubit({
    required ProgressRepository progressRepository,
    required this.owner,
    required List<ExerciseModel> exercises,
    this.lesson,
    this.config = const PracticeSessionConfig.lesson(),
    ExerciseAttemptFactory attemptFactory = const ExerciseAttemptFactory(),
    LessonCompletionService completionService = const LessonCompletionService(),
    DateTime Function()? now,
  }) : _progress = progressRepository,
       _attemptFactory = attemptFactory,
       _completionService = completionService,
       _now = now ?? _utcNow,
       _startedAt = (now ?? _utcNow)(),
       super(
         ExerciseState(
           exercises: exercises,
           config: config,
           remainingSeconds: config.durationSeconds,
         ),
       ) {
    if (config.isTimed && exercises.isNotEmpty) _startTimer();
  }

  final ProgressRepository _progress;
  final ExerciseAttemptFactory _attemptFactory;
  final LessonCompletionService _completionService;
  final DateTime Function() _now;
  final LearningDataOwner owner;
  final LessonModel? lesson;
  final PracticeSessionConfig config;
  DateTime _startedAt;
  Timer? _timer;

  static DateTime _utcNow() => DateTime.now().toUtc();

  void selectAnswer(String optionId) {
    if (!state.submitted) emit(state.copyWith(selectedOptionId: optionId));
  }

  void showHint() {
    if (!state.submitted) emit(state.copyWith(hintUsed: true));
  }

  Future<void> revealAnswer() async {
    if (!config.allowReveal || state.submitted || state.saving) return;
    await _record(
      selectedAnswer: 'revealed',
      isCorrect: false,
      revealed: true,
      hintUsed: true,
    );
  }

  Future<void> submit() async {
    if (state.selectedOptionId == null || state.submitted || state.saving) {
      return;
    }
    await _record(
      selectedAnswer: state.selectedOptionId!,
      isCorrect: state.current.correctAnswerIds.contains(
        state.selectedOptionId,
      ),
      revealed: false,
      hintUsed: state.hintUsed,
    );
  }

  Future<void> _record({
    required Object selectedAnswer,
    required bool isCorrect,
    required bool revealed,
    required bool hintUsed,
  }) async {
    emit(state.copyWith(saving: true));
    final history = (await _progress.getExerciseAttempts(
      owner,
    )).getOrElse(() => const []);
    final prepared = _attemptFactory.create(
      exercise: state.current,
      history: history,
      selectedAnswer: selectedAnswer,
      isCorrect: isCorrect,
      hintUsed: hintUsed,
      revealed: revealed,
      startedAt: _startedAt,
      now: _now(),
    );
    final result = await _progress.appendExerciseAttempt(
      owner,
      prepared.attempt,
    );
    result.fold(
      (_) => emit(
        state.copyWith(
          saving: false,
          message: 'تعذّر حفظ الإجابة. حاول مرة أخرى.',
        ),
      ),
      (_) => emit(
        state.copyWith(
          saving: false,
          submitted: true,
          revealed: revealed,
          correctCount: state.correctCount + (prepared.score.isCorrect ? 1 : 0),
          earnedWeight:
              state.earnedWeight +
              (prepared.score.isCorrect ? prepared.score.weight : 0),
        ),
      ),
    );
  }

  Future<void> next() async {
    if (!state.submitted) return;
    if (state.isLast) return _completeSession();
    _startedAt = _now();
    emit(
      state.copyWith(
        index: state.index + 1,
        hintUsed: false,
        revealed: false,
        submitted: false,
        clearSelection: true,
      ),
    );
  }

  Future<void> tickTimer() async {
    if (!config.isTimed || state.completed || state.saving) return;
    final remaining = state.remainingSeconds ?? 0;
    if (remaining > 1) {
      emit(state.copyWith(remainingSeconds: remaining - 1));
    } else {
      _timer?.cancel();
      if (!state.submitted) {
        await _record(
          selectedAnswer: 'timeout',
          isCorrect: false,
          revealed: false,
          hintUsed: false,
        );
      }
      emit(
        state.copyWith(remainingSeconds: 0, timedOut: true, completed: true),
      );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => unawaited(tickTimer()),
    );
  }

  Future<void> _completeSession() async {
    _timer?.cancel();
    if (lesson != null && config.mode == PracticeMode.lesson) {
      await _completionService.complete(
        repository: _progress,
        owner: owner,
        lesson: lesson!,
        correctCount: state.correctCount,
        earnedWeight: state.earnedWeight,
        exerciseCount: state.exercises.length,
        now: _now(),
      );
    }
    emit(state.copyWith(completed: true));
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await super.close();
  }
}
