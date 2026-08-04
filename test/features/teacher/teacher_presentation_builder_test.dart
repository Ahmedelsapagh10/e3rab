import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/data_source/local_curriculum_data_source.dart';
import 'package:new_strucuture/features/curriculum/data/local_curriculum_repository.dart';
import 'package:new_strucuture/features/teacher/domain/teacher_presentation_builder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'builds classroom slides for metadata, mistakes, and examples',
    () async {
      final lessons = (await LocalCurriculumRepository(
        AssetCurriculumDataSource(bundle: rootBundle),
      ).getAllLessons()).getOrElse(() => const []);
      final lesson = lessons[1];

      final slides = const TeacherPresentationBuilder().build(lesson, lessons);

      expect(slides.first.title, lesson.title);
      expect(slides.any((slide) => slide.title == 'أهداف الدرس'), isTrue);
      expect(slides.any((slide) => slide.title == 'خطأ شائع'), isTrue);
      expect(slides.any((slide) => slide.example != null), isTrue);
    },
  );
}
