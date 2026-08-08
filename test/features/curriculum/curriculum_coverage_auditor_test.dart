import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/model/grammar_coverage_model.dart';
import 'package:new_strucuture/features/curriculum/services/curriculum_coverage_auditor.dart';

void main() {
  const track = GrammarCoverageTrack(
    id: 'track',
    title: 'باب',
    order: 1,
    topics: ['الأول', 'الثاني'],
    topicIds: ['track.first', 'track.second'],
  );
  const auditor = CurriculumCoverageAuditor();

  test('reports complete coverage only for one lesson per topic', () {
    final report = auditor.audit(
      tracks: const [track],
      lessonTopicIds: const ['track.first', 'track.second'],
    );

    expect(report.isComplete, isTrue);
    expect(report.coveredTopicIds, hasLength(2));
  });

  test('reports missing, unknown, and duplicate topic mappings', () {
    final report = auditor.audit(
      tracks: const [track],
      lessonTopicIds: const ['track.first', 'track.first', 'other.topic'],
    );

    expect(report.isComplete, isFalse);
    expect(report.missingTopicIds, {'track.second'});
    expect(report.unknownTopicIds, {'other.topic'});
    expect(report.duplicateTopicIds, {'track.first'});
  });
}
