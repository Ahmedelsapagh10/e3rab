import '../../curriculum/data/model/lesson_model.dart';

class TeacherSlideModel {
  const TeacherSlideModel({
    required this.title,
    required this.lines,
    this.example,
  });

  final String title;
  final List<String> lines;
  final String? example;
}

class TeacherPresentationBuilder {
  const TeacherPresentationBuilder();

  List<TeacherSlideModel> build(
    LessonModel lesson,
    List<LessonModel> allLessons,
  ) {
    final lessonNames = {for (final item in allLessons) item.id: item.title};
    return [
      TeacherSlideModel(
        title: lesson.title,
        lines: [
          '${lesson.estimatedMinutes} دقيقة',
          '${lesson.exerciseIds.length} تمارين',
          'محتوى قيد المراجعة المتخصصة',
        ],
      ),
      TeacherSlideModel(title: 'أهداف الدرس', lines: lesson.objectives),
      TeacherSlideModel(
        title: 'المتطلبات السابقة',
        lines: lesson.prerequisiteIds.isEmpty
            ? const ['لا توجد متطلبات سابقة مسجلة.']
            : lesson.prerequisiteIds
                  .map((id) => lessonNames[id] ?? id)
                  .toList(),
      ),
      ...lesson.sections.map(
        (section) =>
            TeacherSlideModel(title: section.title, lines: [section.body]),
      ),
      ...lesson.examples.map(
        (example) => TeacherSlideModel(
          title: 'مثال معرَب',
          example: example.fullyDiacritizedSentence,
          lines: [
            example.explanation,
            ...example.parsedWords.map(
              (word) =>
                  '${word.word}: ${word.grammaticalRole}، '
                  '${word.grammaticalState}، ${word.grammaticalSign}.',
            ),
          ],
        ),
      ),
    ];
  }
}
