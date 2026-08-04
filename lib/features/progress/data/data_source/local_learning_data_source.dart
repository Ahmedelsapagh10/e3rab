import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/learning_progress_models.dart';
import '../model/learning_support_models.dart';
import 'learning_data_codec.dart';
import 'learning_support_codec.dart';

class LearningSnapshot {
  const LearningSnapshot({
    required this.progress,
    required this.attempts,
    required this.mastery,
    required this.reviews,
    required this.bookmarks,
    required this.notes,
  });

  final List<LessonProgressModel> progress;
  final List<ExerciseAttemptModel> attempts;
  final List<SkillMasteryModel> mastery;
  final List<ReviewItemModel> reviews;
  final List<BookmarkModel> bookmarks;
  final List<LearningNoteModel> notes;

  bool get isEmpty =>
      progress.isEmpty &&
      attempts.isEmpty &&
      bookmarks.isEmpty &&
      notes.isEmpty;
}

class LocalLearningDataSource {
  LocalLearningDataSource(this._preferences);

  final SharedPreferences _preferences;
  final StreamController<String> _changes = StreamController.broadcast();

  Stream<List<LessonProgressModel>> watchProgress(
    LearningDataOwner owner,
  ) async* {
    yield getProgress(owner);
    await for (final key in _changes.stream) {
      if (key == _key(owner)) yield getProgress(owner);
    }
  }

  List<LessonProgressModel> getProgress(LearningDataOwner owner) =>
      _values(owner, 'progress', LearningDataCodec.progressFrom);

  List<ExerciseAttemptModel> getAttempts(LearningDataOwner owner) =>
      _values(owner, 'attempts', LearningDataCodec.attemptFrom);

  List<SkillMasteryModel> getMastery(LearningDataOwner owner) =>
      _values(owner, 'mastery', LearningSupportCodec.masteryFrom);

  List<ReviewItemModel> getReviews(LearningDataOwner owner) =>
      _values(owner, 'reviews', LearningSupportCodec.reviewFrom);

  List<BookmarkModel> getBookmarks(LearningDataOwner owner) =>
      _values(owner, 'bookmarks', LearningSupportCodec.bookmarkFrom);

  List<LearningNoteModel> getNotes(LearningDataOwner owner) =>
      _values(owner, 'notes', LearningSupportCodec.noteFrom);

  Future<void> saveProgress(LearningDataOwner owner, LessonProgressModel item) {
    return _upsert(
      owner,
      'progress',
      item.lessonId,
      LearningDataCodec.progress(item),
    );
  }

  Future<void> appendAttempt(
    LearningDataOwner owner,
    ExerciseAttemptModel item,
  ) {
    return _upsert(
      owner,
      'attempts',
      item.attemptId,
      LearningDataCodec.attempt(item),
    );
  }

  Future<void> saveMastery(LearningDataOwner owner, SkillMasteryModel item) {
    return _upsert(
      owner,
      'mastery',
      item.skillId,
      LearningSupportCodec.mastery(item),
    );
  }

  Future<void> saveReview(LearningDataOwner owner, ReviewItemModel item) {
    return _upsert(
      owner,
      'reviews',
      item.id,
      LearningSupportCodec.review(item),
    );
  }

  Future<void> saveBookmark(LearningDataOwner owner, BookmarkModel item) {
    return _upsert(
      owner,
      'bookmarks',
      item.id,
      LearningSupportCodec.bookmark(item),
    );
  }

  Future<void> saveNote(LearningDataOwner owner, LearningNoteModel item) {
    return _upsert(owner, 'notes', item.id, LearningSupportCodec.note(item));
  }

  LearningSnapshot snapshot(LearningDataOwner owner) => LearningSnapshot(
    progress: getProgress(owner),
    attempts: getAttempts(owner),
    mastery: getMastery(owner),
    reviews: getReviews(owner),
    bookmarks: getBookmarks(owner),
    notes: getNotes(owner),
  );

  Future<void> clear(LearningDataOwner owner) async {
    await _preferences.remove(_key(owner));
    _changes.add(_key(owner));
  }

  Future<void> resetProgress(LearningDataOwner owner) async {
    final data = _read(owner)
      ..remove('progress')
      ..remove('attempts')
      ..remove('mastery')
      ..remove('reviews');
    await _preferences.setString(_key(owner), jsonEncode(data));
    _changes.add(_key(owner));
  }

  List<T> _values<T>(
    LearningDataOwner owner,
    String collection,
    T Function(Map<String, dynamic>) decode,
  ) {
    final map = _read(owner)[collection] as Map<String, dynamic>? ?? const {};
    return map.values
        .map((value) => decode(Map<String, dynamic>.from(value as Map)))
        .toList(growable: false);
  }

  Future<void> _upsert(
    LearningDataOwner owner,
    String collection,
    String id,
    Map<String, Object?> value,
  ) async {
    final data = _read(owner);
    final items = Map<String, dynamic>.from(
      data[collection] as Map<String, dynamic>? ?? const {},
    );
    items[id] = value;
    data[collection] = items;
    await _preferences.setString(_key(owner), jsonEncode(data));
    _changes.add(_key(owner));
  }

  Map<String, dynamic> _read(LearningDataOwner owner) {
    final raw = _preferences.getString(_key(owner));
    return raw == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  String _key(LearningDataOwner owner) =>
      'e3rab_learning_${owner.type.name}_${owner.id}';

  Future<void> dispose() => _changes.close();
}
