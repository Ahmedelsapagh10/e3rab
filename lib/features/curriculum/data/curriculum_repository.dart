import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'model/curriculum_models.dart';
import 'model/content_reference_model.dart';
import 'model/exercise_model.dart';
import 'model/lesson_model.dart';
import 'model/search_result_model.dart';

abstract class CurriculumRepository {
  Future<Either<Failure, List<LearningPathModel>>> getLearningPaths();

  Future<Either<Failure, List<GrammarModuleModel>>> getModules(String pathId);

  Future<Either<Failure, List<GrammarUnitModel>>> getUnits(String moduleId);

  Future<Either<Failure, LessonModel?>> getLesson(String lessonId);

  Future<Either<Failure, List<ExerciseModel>>> getLessonExercises(
    String lessonId,
  );

  Future<Either<Failure, List<LessonModel>>> getAllLessons();

  Future<Either<Failure, List<ContentReferenceModel>>> getReferences();

  Future<Either<Failure, List<SearchResultModel>>> search(String query);
}
