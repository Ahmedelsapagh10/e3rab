import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/search/arabic_search_ranker.dart';
import '../../curriculum/data/curriculum_repository.dart';
import '../../curriculum/data/model/lesson_model.dart';
import 'grammar_reference_repository.dart';
import 'model/grammar_reference_entry.dart';
import 'model/reference_search_result.dart';

class LocalGrammarReferenceRepository implements GrammarReferenceRepository {
  LocalGrammarReferenceRepository(this._curriculum);

  final CurriculumRepository _curriculum;

  @override
  Future<Either<Failure, List<GrammarReferenceEntry>>> getEntries() async {
    final result = await _curriculum.getAllLessons();
    return result.map(_buildEntries);
  }

  @override
  Future<Either<Failure, List<ReferenceSearchResult>>> search(
    String query,
  ) async {
    return (await getEntries()).map((entries) {
      final results = entries
          .map(
            (entry) => ReferenceSearchResult(
              entry: entry,
              score: ArabicSearchRanker.score(
                query: query,
                title: entry.title,
                keywords: entry.keywords,
                body: entry.body,
              ),
            ),
          )
          .where((result) => result.score > 0)
          .toList();
      results.sort((a, b) {
        final score = b.score.compareTo(a.score);
        return score != 0 ? score : a.entry.title.compareTo(b.entry.title);
      });
      return results;
    });
  }

  List<GrammarReferenceEntry> _buildEntries(List<LessonModel> lessons) {
    return lessons.expand(_lessonEntries).toList(growable: false);
  }

  Iterable<GrammarReferenceEntry> _lessonEntries(LessonModel lesson) sync* {
    final explanation = _section(lesson, 'explanation');
    final summary = _section(lesson, 'summary');
    yield _entry(
      lesson: lesson,
      id: 'dictionary-${lesson.id}',
      type: GrammarReferenceType.dictionary,
      title: lesson.title,
      body: [explanation?.body, summary?.body].whereType<String>().join('\n'),
    );
    for (final section in lesson.sections) {
      final type = switch (section.type) {
        'rule' => GrammarReferenceType.quickRule,
        'comparison' => GrammarReferenceType.comparison,
        'misconceptions' => GrammarReferenceType.commonMistake,
        _ => null,
      };
      if (type == null) continue;
      yield _entry(
        lesson: lesson,
        id: '${type.name}-${lesson.id}',
        type: type,
        title: _title(type, lesson.shortTitle),
        body: section.body,
      );
    }
  }

  GrammarReferenceEntry _entry({
    required LessonModel lesson,
    required String id,
    required GrammarReferenceType type,
    required String title,
    required String body,
  }) {
    return GrammarReferenceEntry(
      id: id,
      type: type,
      title: title,
      body: body,
      keywords: _keywords(lesson),
      lesson: lesson,
    );
  }

  String _keywords(LessonModel lesson) => [
    ...lesson.tags,
    ...lesson.stageIds,
    ...lesson.gradeIds,
    ...lesson.stageIds.map(_academicLabel),
    ...lesson.gradeIds.map(_academicLabel),
    ...lesson.objectives,
    ...lesson.examples.expand(
      (example) => [
        example.sentence,
        example.fullyDiacritizedSentence,
        example.explanation,
        ...example.parsedWords.expand(
          (word) => [
            word.word,
            word.wordType,
            word.grammaticalRole,
            word.grammaticalState,
            word.grammaticalSign,
            word.signReason,
          ],
        ),
      ],
    ),
  ].join(' ');

  String _academicLabel(String id) => switch (id) {
    'foundation' => 'المسار التأسيسي تأسيس',
    'preparatory' => 'المرحلة الإعدادية إعدادي',
    'secondary' => 'المرحلة الثانوية ثانوي',
    'grade-7' => 'الصف الأول الإعدادي أولى إعدادي',
    'grade-12' => 'الصف الثالث الثانوي ثالثة ثانوي',
    'general' => 'المسار العام الحر',
    _ => id,
  };

  LessonSectionModel? _section(LessonModel lesson, String type) =>
      lesson.sections.where((section) => section.type == type).firstOrNull;

  String _title(GrammarReferenceType type, String lessonTitle) =>
      switch (type) {
        GrammarReferenceType.quickRule => 'قاعدة $lessonTitle',
        GrammarReferenceType.comparison => 'قارن في $lessonTitle',
        GrammarReferenceType.commonMistake => 'خطأ شائع: $lessonTitle',
        GrammarReferenceType.dictionary => lessonTitle,
      };
}
