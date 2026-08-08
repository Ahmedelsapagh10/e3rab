import 'package:equatable/equatable.dart';

class GrammarCoverageTrack extends Equatable {
  const GrammarCoverageTrack({
    required this.id,
    required this.title,
    required this.order,
    required this.topics,
    required this.topicIds,
  });

  final String id;
  final String title;
  final int order;
  final List<String> topics;
  final List<String> topicIds;

  @override
  List<Object?> get props => [id, title, order, topics, topicIds];
}
