import 'dart:convert';

import 'package:flutter/services.dart';

import 'model/grammar_coverage_model.dart';

abstract class GrammarCoverageRepository {
  Future<List<GrammarCoverageTrack>> getTracks();
}

class LocalGrammarCoverageRepository implements GrammarCoverageRepository {
  LocalGrammarCoverageRepository({required AssetBundle bundle})
    : _bundle = bundle;

  final AssetBundle _bundle;

  @override
  Future<List<GrammarCoverageTrack>> getTracks() async {
    final source = await _bundle.loadString(
      'assets/content/e3rab_grammar_coverage_v2.json',
    );
    final json = Map<String, dynamic>.from(jsonDecode(source) as Map);
    if (json['schemaVersion'] != 2 || json['tracks'] is! List) {
      throw const FormatException('Invalid grammar coverage catalog.');
    }
    final ids = <String>{};
    final tracks = (json['tracks'] as List).map((value) {
      final item = Map<String, dynamic>.from(value as Map);
      final id = item['id'] as String;
      final topics = List<String>.from(item['topics'] as List);
      if (!ids.add(id) ||
          topics.isEmpty ||
          topics.toSet().length != topics.length) {
        throw FormatException('Invalid or duplicate grammar track: $id');
      }
      return GrammarCoverageTrack(
        id: id,
        title: item['title'] as String,
        order: item['order'] as int,
        topics: topics,
      );
    }).toList();
    tracks.sort((a, b) => a.order.compareTo(b.order));
    return tracks;
  }
}
