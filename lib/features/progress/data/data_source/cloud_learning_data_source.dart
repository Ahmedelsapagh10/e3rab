import '../model/learning_progress_models.dart';
import '../model/learning_support_models.dart';
import 'local_learning_data_source.dart';

abstract class CloudLearningDataSource {
  Future<LearningSnapshot> fetch(String uid);

  Future<void> saveProgress(String uid, LessonProgressModel item);

  Future<void> appendAttempt(String uid, ExerciseAttemptModel item);

  Future<void> saveMastery(String uid, SkillMasteryModel item);

  Future<void> saveReview(String uid, ReviewItemModel item);

  Future<void> saveBookmark(String uid, BookmarkModel item);

  Future<void> saveNote(String uid, LearningNoteModel item);

  Future<void> resetProgress(String uid);
}
