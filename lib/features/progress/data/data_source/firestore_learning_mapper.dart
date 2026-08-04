import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/learning_progress_models.dart';
import '../model/learning_support_models.dart';
import 'learning_data_codec.dart';
import 'learning_support_codec.dart';

abstract final class FirestoreLearningMapper {
  static LessonProgressModel progress(Map<String, dynamic> data) {
    return LearningDataCodec.progressFrom(_dates(data));
  }

  static ExerciseAttemptModel attempt(Map<String, dynamic> data) {
    return LearningDataCodec.attemptFrom(_dates(data));
  }

  static SkillMasteryModel mastery(Map<String, dynamic> data) {
    return LearningSupportCodec.masteryFrom(_dates(data));
  }

  static ReviewItemModel review(String id, Map<String, dynamic> data) {
    return LearningSupportCodec.reviewFrom({..._dates(data), 'id': id});
  }

  static BookmarkModel bookmark(String id, Map<String, dynamic> data) {
    return LearningSupportCodec.bookmarkFrom({..._dates(data), 'id': id});
  }

  static LearningNoteModel note(String id, Map<String, dynamic> data) {
    return LearningSupportCodec.noteFrom({..._dates(data), 'id': id});
  }

  static Map<String, dynamic> _dates(Map<String, dynamic> source) {
    return source.map((key, value) {
      if (value is Timestamp) {
        return MapEntry(key, value.toDate().toIso8601String());
      }
      return MapEntry(key, value);
    });
  }
}
