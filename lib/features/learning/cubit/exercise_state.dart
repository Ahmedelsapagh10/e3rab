import 'package:equatable/equatable.dart';

import '../../curriculum/data/model/exercise_model.dart';
import '../../practice/domain/practice_session_config.dart';

class ExerciseState extends Equatable {
  const ExerciseState({
    required this.exercises,
    required this.config,
    this.index = 0,
    this.correctCount = 0,
    this.earnedWeight = 0,
    this.hintUsed = false,
    this.revealed = false,
    this.timedOut = false,
    this.submitted = false,
    this.completed = false,
    this.saving = false,
    this.selectedOptionId,
    this.remainingSeconds,
    this.message,
  });

  final List<ExerciseModel> exercises;
  final PracticeSessionConfig config;
  final int index;
  final int correctCount;
  final double earnedWeight;
  final bool hintUsed;
  final bool revealed;
  final bool timedOut;
  final bool submitted;
  final bool completed;
  final bool saving;
  final String? selectedOptionId;
  final int? remainingSeconds;
  final String? message;

  ExerciseModel get current => exercises[index];
  bool get isCorrect =>
      !revealed && current.correctAnswerIds.contains(selectedOptionId);
  bool get isLast => index == exercises.length - 1;
  double get score => exercises.isEmpty ? 0 : correctCount / exercises.length;
  double get weightedScore =>
      exercises.isEmpty ? 0 : earnedWeight / exercises.length;

  ExerciseState copyWith({
    int? index,
    int? correctCount,
    double? earnedWeight,
    bool? hintUsed,
    bool? revealed,
    bool? timedOut,
    bool? submitted,
    bool? completed,
    bool? saving,
    String? selectedOptionId,
    int? remainingSeconds,
    bool clearSelection = false,
    String? message,
  }) {
    return ExerciseState(
      exercises: exercises,
      config: config,
      index: index ?? this.index,
      correctCount: correctCount ?? this.correctCount,
      earnedWeight: earnedWeight ?? this.earnedWeight,
      hintUsed: hintUsed ?? this.hintUsed,
      revealed: revealed ?? this.revealed,
      timedOut: timedOut ?? this.timedOut,
      submitted: submitted ?? this.submitted,
      completed: completed ?? this.completed,
      saving: saving ?? this.saving,
      selectedOptionId: clearSelection
          ? null
          : selectedOptionId ?? this.selectedOptionId,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    exercises,
    config,
    index,
    correctCount,
    earnedWeight,
    hintUsed,
    revealed,
    timedOut,
    submitted,
    completed,
    saving,
    selectedOptionId,
    remainingSeconds,
    message,
  ];
}
