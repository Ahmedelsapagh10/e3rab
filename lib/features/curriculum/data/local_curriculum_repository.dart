import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/search/arabic_search_normalizer.dart';
import 'curriculum_repository.dart';
import 'data_source/local_curriculum_data_source.dart';
import 'model/curriculum_models.dart';
import 'model/content_reference_model.dart';
import 'model/exercise_model.dart';
import 'model/lesson_model.dart';
import 'model/search_result_model.dart';

class LocalCurriculumRepository implements CurriculumRepository {
  LocalCurriculumRepository(this._dataSource);

  final LocalCurriculumDataSource _dataSource;

  @override
  Future<Either<Failure, List<LearningPathModel>>> getLearningPaths() async {
    return const Right([
      LearningPathModel(
        id: 'vertical-slice',
        slug: 'e3rab-vertical-slice',
        title: 'مسار إعراب التجريبي',
        moduleIds: ['foundation-module', 'sentence-module', 'advanced-module'],
        isFreeOrder: false,
      ),
    ]);
  }

  @override
  Future<Either<Failure, List<GrammarModuleModel>>> getModules(String pathId) {
    return _run(() => _dataSource.modules);
  }

  @override
  Future<Either<Failure, List<GrammarUnitModel>>> getUnits(String moduleId) {
    return _run(
      () =>
          _dataSource.units.where((unit) => unit.moduleId == moduleId).toList(),
    );
  }

  @override
  Future<Either<Failure, List<LessonModel>>> getAllLessons() {
    return _run(() => _dataSource.lessons);
  }

  @override
  Future<Either<Failure, List<ContentReferenceModel>>> getReferences() {
    return _run(() => _dataSource.references);
  }

  @override
  Future<Either<Failure, LessonModel?>> getLesson(String lessonId) {
    return _run(() {
      return _dataSource.lessons
          .where((lesson) => lesson.id == lessonId)
          .firstOrNull;
    });
  }

  @override
  Future<Either<Failure, List<ExerciseModel>>> getLessonExercises(
    String lessonId,
  ) {
    return _run(
      () => _dataSource.exercises
          .where((exercise) => exercise.lessonId == lessonId)
          .toList(),
    );
  }

  @override
  Future<Either<Failure, List<SearchResultModel>>> search(String query) {
    return _run(() {
      final key = ArabicSearchNormalizer.normalize(query);
      if (key.isEmpty) return const <SearchResultModel>[];
      final results = <SearchResultModel>[];
      for (final lesson in _dataSource.lessons) {
        final title = ArabicSearchNormalizer.normalize(lesson.title);
        final tags = ArabicSearchNormalizer.normalize(lesson.tags.join(' '));
        final body = ArabicSearchNormalizer.normalize(
          lesson.sections.map((section) => section.body).join(' '),
        );
        final score = title.contains(key)
            ? 10
            : tags.contains(key)
            ? 6
            : body.contains(key)
            ? 2
            : 0;
        if (score > 0) {
          results.add(
            SearchResultModel(
              lesson: lesson,
              matchedText: lesson.title,
              score: score,
            ),
          );
        }
      }
      results.sort((a, b) => b.score.compareTo(a.score));
      return results;
    });
  }

  Future<Either<Failure, T>> _run<T>(T Function() read) async {
    try {
      await _dataSource.load();
      return Right(read());
    } catch (_) {
      return Left(CacheFailure());
    }
  }
}
