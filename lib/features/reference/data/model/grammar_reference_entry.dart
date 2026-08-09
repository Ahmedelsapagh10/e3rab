import 'package:equatable/equatable.dart';

import '../../../curriculum/data/model/content_review_status.dart';
import '../../../curriculum/data/model/lesson_model.dart';

enum GrammarReferenceType { dictionary, quickRule, comparison, commonMistake }

extension GrammarReferenceTypeLabel on GrammarReferenceType {
  String get label => switch (this) {
    GrammarReferenceType.dictionary => 'القاموس النحوي',
    GrammarReferenceType.quickRule => 'قواعد سريعة',
    GrammarReferenceType.comparison => 'مقارنات',
    GrammarReferenceType.commonMistake => 'أخطاء شائعة',
  };
}

class GrammarReferenceEntry extends Equatable {
  const GrammarReferenceEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.keywords,
    required this.lesson,
  });

  final String id;
  final GrammarReferenceType type;
  final String title;
  final String body;
  final String keywords;
  final LessonModel lesson;

  String get contentVersion => lesson.contentVersion;
  ContentReviewStatus get reviewStatus => lesson.reviewStatus;
  bool get isApproved => reviewStatus == ContentReviewStatus.approved;
  bool get isLearnerReady => reviewStatus.isLearnerReady;

  @override
  List<Object?> get props => [id, type, title, body, keywords, lesson];
}
