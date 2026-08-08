import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../progress/data/model/learning_progress_models.dart';
import '../../progress/data/model/learning_support_models.dart';
import '../../progress/data/progress_repository.dart';
import '../data/grammar_analysis_service.dart';
import 'parsing_state.dart';

class ParsingCubit extends Cubit<ParsingState> {
  ParsingCubit(
    this._analysisService,
    this._progress,
    this.owner, {
    bool? allowDraftPreview,
    DateTime Function()? now,
  }) : _allowDraftPreview =
           allowDraftPreview ??
           (kDebugMode &&
               const bool.fromEnvironment('E3RAB_ENABLE_DRAFT_PARSING')),
       _now = now ?? _utcNow,
       super(const ParsingState());

  final GrammarAnalysisService _analysisService;
  final ProgressRepository _progress;
  final LearningDataOwner owner;
  final bool _allowDraftPreview;
  final DateTime Function() _now;

  static DateTime _utcNow() => DateTime.now().toUtc();

  Future<void> load() async {
    emit(state.copyWith(status: ParsingLabStatus.loading));
    final result = await _analysisService.getSamples(
      includeDrafts: _allowDraftPreview,
    );
    await result.fold(
      (_) async => emit(
        state.copyWith(
          status: ParsingLabStatus.failure,
          message: 'تعذّر فتح بنك الإعراب المحلي.',
        ),
      ),
      (samples) async {
        if (samples.isEmpty) {
          emit(state.copyWith(status: ParsingLabStatus.empty));
          return;
        }
        final saved = await _isSaved(samples.first.id);
        emit(
          ParsingState(
            status: ParsingLabStatus.ready,
            samples: samples,
            allSamples: samples,
            saved: saved,
            previewMode: _allowDraftPreview && !samples.first.isApproved,
          ),
        );
      },
    );
  }

  Future<void> selectTrack(String? trackId) async {
    await _applyFilters(trackId: trackId, difficulty: state.selectedDifficulty);
  }

  Future<void> selectDifficulty(int? difficulty) async {
    await _applyFilters(trackId: state.selectedTrackId, difficulty: difficulty);
  }

  Future<void> _applyFilters({String? trackId, int? difficulty}) async {
    final filtered = state.allSamples.where((sample) {
      return (trackId == null || sample.trackId == trackId) &&
          (difficulty == null || sample.difficulty == difficulty);
    }).toList()..sort((a, b) => a.order.compareTo(b.order));
    if (filtered.isEmpty) return;
    emit(
      ParsingState(
        status: ParsingLabStatus.ready,
        samples: filtered,
        allSamples: state.allSamples,
        selectedTrackId: trackId,
        selectedDifficulty: difficulty,
        saved: await _isSaved(filtered.first.id),
        previewMode: _allowDraftPreview && !filtered.first.isApproved,
      ),
    );
  }

  void selectOption(String optionId) {
    if (!state.submitted) emit(state.copyWith(selectedOptionId: optionId));
  }

  void submit() {
    if (state.selectedOptionId == null || state.submitted) return;
    emit(
      state.copyWith(
        submitted: true,
        correctCount: state.correctCount + (state.isCorrect ? 1 : 0),
      ),
    );
  }

  void nextStep() {
    if (!state.submitted) return;
    if (state.isLastStep) {
      emit(state.copyWith(completed: true));
      return;
    }
    emit(
      state.copyWith(
        stepIndex: state.stepIndex + 1,
        submitted: false,
        clearSelection: true,
      ),
    );
  }

  Future<void> nextSample() async {
    final index = (state.sampleIndex + 1) % state.samples.length;
    final sample = state.samples[index];
    emit(
      ParsingState(
        status: ParsingLabStatus.ready,
        samples: state.samples,
        allSamples: state.allSamples,
        sampleIndex: index,
        saved: await _isSaved(sample.id),
        previewMode: _allowDraftPreview && !sample.isApproved,
        selectedTrackId: state.selectedTrackId,
        selectedDifficulty: state.selectedDifficulty,
      ),
    );
  }

  Future<void> toggleSaved() async {
    final sample = state.currentSample;
    final now = _now();
    final bookmark = BookmarkModel(
      id: 'parsing-${sample.id}',
      targetType: 'parsingSample',
      targetId: sample.id,
      contentVersion: sample.contentVersion,
      createdAt: now,
      updatedAt: now,
      deletedAt: state.saved ? now : null,
    );
    final result = await _progress.saveBookmark(owner, bookmark);
    if (result.isRight()) emit(state.copyWith(saved: !state.saved));
  }

  Future<void> reportError(String text) async {
    if (text.trim().isEmpty) return;
    emit(state.copyWith(reportSaved: false));
    final now = _now();
    final report = LearningNoteModel(
      id: 'parsing-report-${state.currentSample.id}-${now.microsecondsSinceEpoch}',
      targetType: 'parsingReport',
      targetId: state.currentSample.id,
      text: text.trim(),
      localVersion: 1,
      updatedAt: now,
      schemaVersion: 1,
    );
    final result = await _progress.saveNote(owner, report);
    if (result.isRight()) emit(state.copyWith(reportSaved: true));
  }

  Future<bool> _isSaved(String sampleId) async {
    final bookmarks = (await _progress.getBookmarks(
      owner,
    )).getOrElse(() => const []);
    return bookmarks.any(
      (item) =>
          item.targetType == 'parsingSample' &&
          item.targetId == sampleId &&
          !item.isDeleted,
    );
  }
}
