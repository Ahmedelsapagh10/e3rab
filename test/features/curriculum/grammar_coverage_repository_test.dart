import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/grammar_coverage_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'comprehensive grammar map has ordered unique tracks and topics',
    () async {
      final repository = LocalGrammarCoverageRepository(bundle: rootBundle);

      final tracks = await repository.getTracks();
      final topics = tracks.expand((track) => track.topics).toList();
      final topicIds = tracks.expand((track) => track.topicIds).toList();

      expect(tracks, hasLength(18));
      expect(topics.length, greaterThanOrEqualTo(120));
      expect(topicIds, hasLength(topics.length));
      expect(topicIds.toSet(), hasLength(125));
      expect(tracks.map((track) => track.id).toSet(), hasLength(tracks.length));
      expect(
        tracks.every(
          (track) =>
              track.topics.toSet().length == track.topics.length &&
              track.topicIds.length == track.topics.length,
        ),
        isTrue,
      );
      expect(tracks.first.title, 'أساسيات الكلام والإعراب');
      expect(tracks.last.title, 'الإعراب التطبيقي');
    },
  );
}
