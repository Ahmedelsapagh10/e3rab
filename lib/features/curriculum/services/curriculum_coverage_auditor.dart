import '../data/model/grammar_coverage_model.dart';

class CurriculumCoverageReport {
  const CurriculumCoverageReport({
    required this.expectedTopicIds,
    required this.coveredTopicIds,
    required this.missingTopicIds,
    required this.unknownTopicIds,
    required this.duplicateTopicIds,
  });

  final Set<String> expectedTopicIds;
  final Set<String> coveredTopicIds;
  final Set<String> missingTopicIds;
  final Set<String> unknownTopicIds;
  final Set<String> duplicateTopicIds;

  bool get isComplete =>
      missingTopicIds.isEmpty &&
      unknownTopicIds.isEmpty &&
      duplicateTopicIds.isEmpty;
}

class CurriculumCoverageAuditor {
  const CurriculumCoverageAuditor();

  CurriculumCoverageReport audit({
    required Iterable<GrammarCoverageTrack> tracks,
    required Iterable<String?> lessonTopicIds,
  }) {
    final expected = tracks.expand((track) => track.topicIds).toSet();
    final counts = <String, int>{};
    for (final topicId in lessonTopicIds) {
      if (topicId == null || topicId.trim().isEmpty) continue;
      counts.update(topicId, (value) => value + 1, ifAbsent: () => 1);
    }
    final covered = counts.keys.toSet();
    return CurriculumCoverageReport(
      expectedTopicIds: Set.unmodifiable(expected),
      coveredTopicIds: Set.unmodifiable(covered.intersection(expected)),
      missingTopicIds: Set.unmodifiable(expected.difference(covered)),
      unknownTopicIds: Set.unmodifiable(covered.difference(expected)),
      duplicateTopicIds: Set.unmodifiable(
        counts.entries
            .where((entry) => entry.value > 1)
            .map((entry) => entry.key)
            .toSet(),
      ),
    );
  }
}
