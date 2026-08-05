import '../model/content_review_status.dart';
import '../model/content_reference_model.dart';
import '../model/curriculum_models.dart';
import '../model/exercise_model.dart';
import '../model/lesson_model.dart';
import '../model/lesson_step_model.dart';

abstract final class ContentPackMapper {
  static ContentReferenceModel reference(Map<String, dynamic> json) {
    return ContentReferenceModel(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      publisher: json['publisher'] as String,
      checkedAt: DateTime.parse(json['checkedAt'] as String),
    );
  }

  static GrammarModuleModel module(Map<String, dynamic> json) {
    return GrammarModuleModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      unitIds: _strings(json['unitIds']),
      order: json['order'] as int,
    );
  }

  static GrammarUnitModel unit(Map<String, dynamic> json) {
    return GrammarUnitModel(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      lessonIds: _strings(json['lessonIds']),
      order: json['order'] as int,
    );
  }

  static LessonModel lesson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      unitId: json['unitId'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      shortTitle: json['shortTitle'] as String,
      stageIds: _strings(json['stageIds']),
      gradeIds: _strings(json['gradeIds']),
      objectives: _strings(json['objectives']),
      prerequisiteIds: _strings(json['prerequisiteIds']),
      sections: _maps(json['sections']).map(section).toList(),
      examples: _maps(json['examples']).map(example).toList(),
      exerciseIds: _strings(json['exerciseIds']),
      referenceIds: _strings(json['referenceIds']),
      tags: _strings(json['tags']),
      estimatedMinutes: json['estimatedMinutes'] as int,
      contentVersion: json['contentVersion'] as String,
      reviewStatus: contentReviewStatusFromJson(json['reviewStatus'] as String),
      steps: _optionalMaps(json['steps']).map(lessonStep).toList(),
      citations: _optionalMaps(json['citations']).map(citation).toList(),
      reviewedBy: json['reviewedBy'] as String?,
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
    );
  }

  static LessonStepModel lessonStep(Map<String, dynamic> json) {
    return LessonStepModel(
      id: json['id'] as String,
      type: LessonStepType.values.byName(json['type'] as String),
      title: json['title'] as String,
      order: json['order'] as int,
      blocks: _optionalMaps(json['blocks']).map(contentBlock).toList(),
      quickCheck: json['quickCheck'] is Map
          ? quickCheck(Map<String, dynamic>.from(json['quickCheck'] as Map))
          : null,
    );
  }

  static ContentBlockModel contentBlock(Map<String, dynamic> json) {
    return ContentBlockModel(
      id: json['id'] as String,
      type: ContentBlockType.values.byName(json['type'] as String),
      title: json['title'] as String?,
      body: json['body'] as String,
      citationIds: _optionalStrings(json['citationIds']),
    );
  }

  static QuickCheckModel quickCheck(Map<String, dynamic> json) {
    return QuickCheckModel(
      prompt: json['prompt'] as String,
      options: Map<String, String>.from(json['options'] as Map),
      correctOptionId: json['correctOptionId'] as String,
      explanation: json['explanation'] as String,
    );
  }

  static CitationModel citation(Map<String, dynamic> json) {
    return CitationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      locator: json['locator'] as String,
      referenceId: json['referenceId'] as String,
    );
  }

  static LessonSectionModel section(Map<String, dynamic> json) {
    return LessonSectionModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      order: json['order'] as int,
      referenceIds: _strings(json['referenceIds']),
    );
  }

  static GrammarExampleModel example(Map<String, dynamic> json) {
    return GrammarExampleModel(
      id: json['id'] as String,
      sentence: json['sentence'] as String,
      fullyDiacritizedSentence: json['fullyDiacritizedSentence'] as String,
      parsedWords: _maps(json['parsedWords']).map(parsedWord).toList(),
      explanation: json['explanation'] as String,
      referenceIds: _strings(json['referenceIds']),
    );
  }

  static ParsedWordModel parsedWord(Map<String, dynamic> json) {
    return ParsedWordModel(
      word: json['word'] as String,
      normalizedWord: json['normalizedWord'] as String,
      wordType: json['wordType'] as String,
      grammaticalRole: json['grammaticalRole'] as String,
      grammaticalState: json['grammaticalState'] as String,
      grammaticalSign: json['grammaticalSign'] as String,
      signReason: json['signReason'] as String,
      explanation: json['explanation'] as String,
      startIndex: json['startIndex'] as int,
      endIndex: json['endIndex'] as int,
    );
  }

  static ExerciseModel exercise(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      type: ExerciseType.values.byName(json['type'] as String),
      prompt: json['prompt'] as String,
      skillIds: _strings(json['skillIds']),
      stageIds: _strings(json['stageIds']),
      gradeIds: _strings(json['gradeIds']),
      difficulty: json['difficulty'] as int,
      options: _maps(json['options']).map(option).toList(),
      correctAnswerIds: _strings(json['correctAnswerIds']),
      explanation: json['explanation'] as String,
      hint: json['hint'] as String,
      referenceIds: _strings(json['referenceIds']),
      contentVersion: json['contentVersion'] as String,
      reviewStatus: contentReviewStatusFromJson(json['reviewStatus'] as String),
      schemaVersion: json['schemaVersion'] as int,
    );
  }

  static ExerciseOptionModel option(Map<String, dynamic> json) {
    return ExerciseOptionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      feedback: json['feedback'] as String,
    );
  }

  static List<String> _strings(Object? value) =>
      List<String>.from(value as List);

  static List<Map<String, dynamic>> _maps(Object? value) {
    return (value as List).cast<Map<String, dynamic>>();
  }

  static List<String> _optionalStrings(Object? value) =>
      value is List ? value.whereType<String>().toList() : const [];

  static List<Map<String, dynamic>> _optionalMaps(Object? value) =>
      value is List
      ? value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
      : const [];
}
