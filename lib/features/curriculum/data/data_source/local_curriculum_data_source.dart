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
  }) : _bundle = bundle,
       _validator = validator;

  final AssetBundle _bundle;
  final ContentValidationService _validator;
  final String assetPath;
  Map<String, dynamic>? _pack;

  @override
  Future<void> load() async {
    if (_pack != null) return;
    final decoded = jsonDecode(await _bundle.loadString(assetPath));
    final pack = Map<String, dynamic>.from(decoded as Map);
    final report = _validator.validate(pack);
    if (!report.isValid) {
      throw FormatException('Invalid E3rab content pack: ${report.errors}');
    }
    _pack = pack;
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
