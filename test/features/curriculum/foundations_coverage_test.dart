import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every foundations coverage topic has a lesson', () async {
    final reviewPack = await _loadPack(
      'assets/content/e3rab_general_foundations_batch1_v1.json',
    );
    final publishedPack = await _loadPack(
      'assets/content/e3rab_vertical_slice_v1.json',
    );
    final reviewLessons = reviewPack['lessons'] as List;
    final publishedLessons = publishedPack['lessons'] as List;
    final topicIds = [...reviewLessons, ...publishedLessons]
        .whereType<Map>()
        .map((lesson) => lesson['topicId'])
        .whereType<String>()
        .toSet();

    expect(topicIds, containsAll(_foundationsTopicIds));
  });
}

Future<Map<String, dynamic>> _loadPack(String path) async =>
    Map<String, dynamic>.from(
      jsonDecode(await rootBundle.loadString(path)) as Map,
    );

const _foundationsTopicIds = {
  'foundations.speech-word-expression',
  'foundations.parts-of-speech',
  'foundations.inflection-building',
  'foundations.inflection-forms',
  'foundations.governor-governed',
  'foundations.sentence-types',
};
