import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/content_validation/content_validation_service.dart';
import '../model/curriculum_models.dart';
import '../model/content_reference_model.dart';
import '../model/exercise_model.dart';
import '../model/lesson_model.dart';
import 'content_pack_mapper.dart';

abstract class LocalCurriculumDataSource {
  Future<void> load();

  List<GrammarModuleModel> get modules;
  List<GrammarUnitModel> get units;
  List<LessonModel> get lessons;
  List<ExerciseModel> get exercises;
  List<ContentReferenceModel> get references;
}

class AssetCurriculumDataSource implements LocalCurriculumDataSource {
  AssetCurriculumDataSource({
    required AssetBundle bundle,
    ContentValidationService validator = const ContentValidationService(),
    this.assetPath = 'assets/content/e3rab_vertical_slice_v1.json',
    this.assetPaths,
  }) : _bundle = bundle,
       _validator = validator;

  final AssetBundle _bundle;
  final ContentValidationService _validator;
  final String assetPath;
  final List<String>? assetPaths;
  Map<String, dynamic>? _pack;

  @override
  Future<void> load() async {
    if (_pack != null) return;
    final combined = <String, dynamic>{
      for (final key in const [
        'modules',
        'units',
        'lessons',
        'exercises',
        'references',
      ])
        key: <dynamic>[],
    };
    final entityIds = <String>{};
    for (final path in assetPaths ?? [assetPath]) {
      final decoded = jsonDecode(await _bundle.loadString(path));
      final pack = Map<String, dynamic>.from(decoded as Map);
      final report = _validator.validate(pack);
      if (!report.isValid) {
        throw FormatException('Invalid E3rab content pack: ${report.errors}');
      }
      for (final key in combined.keys) {
        for (final value in pack[key] as List) {
          final item = Map<String, dynamic>.from(value as Map);
          final id = item['id'] as String;
          if (!entityIds.add(id)) {
            throw FormatException('Duplicate cross-pack entity ID: $id');
          }
          (combined[key] as List).add(item);
        }
      }
    }
    final lessons = (combined['lessons'] as List).cast<Map<String, dynamic>>();
    _validateCombinedIdentity(lessons);
    _validateCombinedPrerequisites(lessons);
    _pack = combined;
  }

  void _validateCombinedIdentity(List<Map<String, dynamic>> lessons) {
    final topicIds = <String>{};
    final orders = <int>{};
    for (final lesson in lessons) {
      final topicId = lesson['topicId'];
      final order = lesson['order'];
      if (topicId is! String ||
          topicId.trim().isEmpty ||
          !topicIds.add(topicId) ||
          order is! int ||
          !orders.add(order)) {
        throw FormatException(
          'Duplicate or missing lesson topic/order: ${lesson['id']}.',
        );
      }
    }
  }

  void _validateCombinedPrerequisites(List<Map<String, dynamic>> lessons) {
    final ids = lessons
        .map((lesson) => lesson['id'])
        .whereType<String>()
        .toSet();
    final graph = <String, List<String>>{};
    for (final lesson in lessons) {
      final id = lesson['id'] as String;
      final dependencies = List<String>.from(
        lesson['prerequisiteIds'] as List? ?? const [],
      );
      if (!ids.containsAll(dependencies)) {
        throw FormatException('Unknown cross-pack prerequisite for $id.');
      }
      graph[id] = dependencies;
    }
    final visiting = <String>{};
    final visited = <String>{};
    bool visit(String id) {
      if (visiting.contains(id)) return false;
      if (visited.contains(id)) return true;
      visiting.add(id);
      for (final dependency in graph[id] ?? const []) {
        if (!visit(dependency)) return false;
      }
      visiting.remove(id);
      visited.add(id);
      return true;
    }

    if (graph.keys.any((id) => !visit(id))) {
      throw const FormatException('Cyclic cross-pack lesson prerequisites.');
    }
  }

  @override
  List<GrammarModuleModel> get modules =>
      _mapList('modules', ContentPackMapper.module);

  @override
  List<GrammarUnitModel> get units => _mapList('units', ContentPackMapper.unit);

  @override
  List<LessonModel> get lessons =>
      _mapList('lessons', ContentPackMapper.lesson);

  @override
  List<ExerciseModel> get exercises =>
      _mapList('exercises', ContentPackMapper.exercise);

  @override
  List<ContentReferenceModel> get references =>
      _mapList('references', ContentPackMapper.reference);

  List<T> _mapList<T>(String key, T Function(Map<String, dynamic>) mapper) {
    final values = _pack?[key] as List?;
    if (values == null) throw StateError('Content must be loaded first.');
    return values
        .map((value) => mapper(Map<String, dynamic>.from(value as Map)))
        .toList(growable: false);
  }
}
