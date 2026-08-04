import 'package:equatable/equatable.dart';

import '../data/model/parsing_models.dart';

enum ParsingLabStatus { initial, loading, ready, empty, failure }

class ParsingState extends Equatable {
  const ParsingState({
    this.status = ParsingLabStatus.initial,
    this.samples = const [],
    this.sampleIndex = 0,
    this.stepIndex = 0,
    this.correctCount = 0,
    this.submitted = false,
    this.completed = false,
    this.saved = false,
    this.previewMode = false,
    this.reportSaved = false,
    this.selectedOptionId,
    this.message,
  });

  final ParsingLabStatus status;
  final List<ParsingSampleModel> samples;
  final int sampleIndex;
  final int stepIndex;
  final int correctCount;
  final bool submitted;
  final bool completed;
  final bool saved;
  final bool previewMode;
  final bool reportSaved;
  final String? selectedOptionId;
  final String? message;

  ParsingSampleModel get currentSample => samples[sampleIndex];
  ParsingStepModel get currentStep => currentSample.steps[stepIndex];
  bool get isCorrect => selectedOptionId == currentStep.correctOptionId;
  bool get isLastStep => stepIndex == currentSample.steps.length - 1;
  double get score => currentSample.steps.isEmpty
      ? 0
      : correctCount / currentSample.steps.length;

  ParsingState copyWith({
    ParsingLabStatus? status,
    List<ParsingSampleModel>? samples,
    int? sampleIndex,
    int? stepIndex,
    int? correctCount,
    bool? submitted,
    bool? completed,
    bool? saved,
    bool? previewMode,
    bool? reportSaved,
    String? selectedOptionId,
    bool clearSelection = false,
    String? message,
  }) {
    return ParsingState(
      status: status ?? this.status,
      samples: samples ?? this.samples,
      sampleIndex: sampleIndex ?? this.sampleIndex,
      stepIndex: stepIndex ?? this.stepIndex,
      correctCount: correctCount ?? this.correctCount,
      submitted: submitted ?? this.submitted,
      completed: completed ?? this.completed,
      saved: saved ?? this.saved,
      previewMode: previewMode ?? this.previewMode,
      reportSaved: reportSaved ?? this.reportSaved,
      selectedOptionId: clearSelection
          ? null
          : selectedOptionId ?? this.selectedOptionId,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    samples,
    sampleIndex,
    stepIndex,
    correctCount,
    submitted,
    completed,
    saved,
    previewMode,
    reportSaved,
    selectedOptionId,
    message,
  ];
}
