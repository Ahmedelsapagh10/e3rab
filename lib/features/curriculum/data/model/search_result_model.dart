import 'package:equatable/equatable.dart';

import 'lesson_model.dart';

class SearchResultModel extends Equatable {
  const SearchResultModel({
    required this.lesson,
    required this.matchedText,
    required this.score,
  });

  final LessonModel lesson;
  final String matchedText;
  final int score;

  @override
  List<Object?> get props => [lesson, matchedText, score];
}
