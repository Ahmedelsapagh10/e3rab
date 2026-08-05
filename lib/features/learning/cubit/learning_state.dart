import 'package:equatable/equatable.dart';

import '../../curriculum/data/model/exercise_model.dart';
import '../../curriculum/data/model/content_reference_model.dart';
import '../../curriculum/data/model/lesson_model.dart';
import '../../curriculum/data/model/search_result_model.dart';
import '../../curriculum/data/model/grammar_coverage_model.dart';
import '../../progress/data/model/learning_progress_models.dart';
import '../../progress/data/model/learning_support_models.dart';

enum LearningStatus { initial, loading, ready, failure }

class LearningState extends Equatable {
  const LearningState({
    this.status = LearningStatus.initial,
    this.lessons = const [],
    this.exercises = const {},
    this.progress = const [],
    this.bookmarks = const [],
    this.notes = const [],
    this.mastery = const [],
    this.reviews = const [],
    this.searchResults = const [],
    this.references = const [],
    this.coverageTracks = const [],
    this.message,
  });

  final LearningStatus status;
  final List<LessonModel> lessons;
  final Map<String, List<ExerciseModel>> exercises;
  final List<LessonProgressModel> progress;
  final List<BookmarkModel> bookmarks;
  final List<LearningNoteModel> notes;
  final List<SkillMasteryModel> mastery;
  final List<ReviewItemModel> reviews;
  final List<SearchResultModel> searchResults;
  final List<ContentReferenceModel> references;
  final List<GrammarCoverageTrack> coverageTracks;
  final String? message;

  LearningState copyWith({
    LearningStatus? status,
    List<LessonModel>? lessons,
    Map<String, List<ExerciseModel>>? exercises,
    List<LessonProgressModel>? progress,
    List<BookmarkModel>? bookmarks,
    List<LearningNoteModel>? notes,
    List<SkillMasteryModel>? mastery,
    List<ReviewItemModel>? reviews,
    List<SearchResultModel>? searchResults,
    List<ContentReferenceModel>? references,
    List<GrammarCoverageTrack>? coverageTracks,
    String? message,
  }) {
    return LearningState(
      status: status ?? this.status,
      lessons: lessons ?? this.lessons,
      exercises: exercises ?? this.exercises,
      progress: progress ?? this.progress,
      bookmarks: bookmarks ?? this.bookmarks,
      notes: notes ?? this.notes,
      mastery: mastery ?? this.mastery,
      reviews: reviews ?? this.reviews,
      searchResults: searchResults ?? this.searchResults,
      references: references ?? this.references,
      coverageTracks: coverageTracks ?? this.coverageTracks,
      message: message,
    );
  }

  LessonProgressModel? progressFor(String lessonId) {
    return progress.where((item) => item.lessonId == lessonId).firstOrNull;
  }

  bool isBookmarked(String lessonId) {
    return bookmarks.any(
      (item) => item.targetId == lessonId && !item.isDeleted,
    );
  }

  LearningNoteModel? noteFor(String lessonId) {
    return notes
        .where((item) => item.targetId == lessonId && item.deletedAt == null)
        .firstOrNull;
  }

  @override
  List<Object?> get props => [
    status,
    lessons,
    exercises,
    progress,
    bookmarks,
    notes,
    mastery,
    reviews,
    searchResults,
    references,
    coverageTracks,
    message,
  ];
}
