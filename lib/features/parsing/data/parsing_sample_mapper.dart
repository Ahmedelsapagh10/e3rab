import '../../curriculum/data/data_source/content_pack_mapper.dart';
import '../../curriculum/data/model/content_review_status.dart';
import 'model/parsing_models.dart';

abstract final class ParsingSampleMapper {
  static ParsingSampleModel fromJson(Map<String, dynamic> json) {
    return ParsingSampleModel(
      id: json['id'] as String,
      sentence: json['sentence'] as String,
      fullyDiacritizedSentence: json['fullyDiacritizedSentence'] as String,
      targetText: json['targetText'] as String,
      steps: _maps(json['steps']).map(_step).toList(),
      parsedWords: _maps(
        json['parsedWords'],
      ).map(ContentPackMapper.parsedWord).toList(),
      summary: json['summary'] as String,
      alternatives: _maps(json['alternatives']).map(_alternative).toList(),
      relatedLessonId: json['relatedLessonId'] as String,
      referenceIds: List<String>.from(json['referenceIds'] as List),
      contentVersion: json['contentVersion'] as String,
      reviewStatus: contentReviewStatusFromJson(json['reviewStatus'] as String),
      trackId: json['trackId'] as String,
      difficulty: json['difficulty'] as int,
      order: json['order'] as int,
      reviewedBy: json['reviewedBy'] as String?,
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
    );
  }

  static ParsingStepModel _step(Map<String, dynamic> json) {
    return ParsingStepModel(
      id: json['id'] as String,
      title: json['title'] as String,
      prompt: json['prompt'] as String,
      options: _maps(json['options']).map(_option).toList(),
      correctOptionId: json['correctOptionId'] as String,
      explanation: json['explanation'] as String,
    );
  }

  static ParsingOptionModel _option(Map<String, dynamic> json) {
    return ParsingOptionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      feedback: json['feedback'] as String,
    );
  }

  static ParsingAlternativeModel _alternative(Map<String, dynamic> json) {
    return ParsingAlternativeModel(
      title: json['title'] as String,
      explanation: json['explanation'] as String,
    );
  }

  static List<Map<String, dynamic>> _maps(Object? value) {
    return (value as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }
}
