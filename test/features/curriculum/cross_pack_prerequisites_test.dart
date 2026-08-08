import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/data_source/local_curriculum_data_source.dart';

void main() {
  test('loads a declared prerequisite that exists in another pack', () async {
    final source = AssetCurriculumDataSource(
      bundle: _MemoryBundle({
        'base.json': _pack(id: 'base', lessonId: 'base-lesson'),
        'next.json': _pack(
          id: 'next',
          lessonId: 'next-lesson',
          prerequisiteId: 'base-lesson',
        ),
      }),
      assetPaths: const ['base.json', 'next.json'],
    );

    await expectLater(source.load(), completes);
  });

  test('rejects a declared prerequisite missing from combined packs', () {
    final source = AssetCurriculumDataSource(
      bundle: _MemoryBundle({
        'next.json': _pack(
          id: 'next',
          lessonId: 'next-lesson',
          prerequisiteId: 'missing-lesson',
        ),
      }),
      assetPaths: const ['next.json'],
    );

    expect(source.load(), throwsFormatException);
  });

  test('rejects a prerequisite cycle spanning content packs', () {
    final source = AssetCurriculumDataSource(
      bundle: _MemoryBundle({
        'one.json': _pack(
          id: 'one',
          lessonId: 'lesson-one',
          prerequisiteId: 'lesson-two',
        ),
        'two.json': _pack(
          id: 'two',
          lessonId: 'lesson-two',
          prerequisiteId: 'lesson-one',
        ),
      }),
      assetPaths: const ['one.json', 'two.json'],
    );

    expect(source.load(), throwsFormatException);
  });

  test('rejects duplicate topic identities across packs', () {
    final source = AssetCurriculumDataSource(
      bundle: _MemoryBundle({
        'one.json': _pack(id: 'one', lessonId: 'lesson-one'),
        'two.json': _pack(
          id: 'two',
          lessonId: 'lesson-two',
          topicId: 'one.topic',
        ),
      }),
      assetPaths: const ['one.json', 'two.json'],
    );

    expect(source.load(), throwsFormatException);
  });
}

String _pack({
  required String id,
  required String lessonId,
  String? prerequisiteId,
  String? topicId,
}) => jsonEncode({
  'manifest': {
    'packId': id,
    'schemaVersion': 1,
    'contentVersion': '1.0.0',
    'curriculumVersion': 'test',
    'locale': 'ar',
    'entityIds': ['$id-module', '$id-unit', lessonId],
    'checksum': 'test',
    'minimumAppVersion': '1.0.0',
    'reviewStatus': 'draft',
    if (prerequisiteId != null) 'externalPrerequisiteIds': [prerequisiteId],
  },
  'modules': [
    {'id': '$id-module', 'slug': '$id-module', 'title': id, 'order': 1},
  ],
  'units': [
    {
      'id': '$id-unit',
      'moduleId': '$id-module',
      'slug': '$id-unit',
      'title': id,
      'order': 1,
    },
  ],
  'lessons': [
    {
      'id': lessonId,
      'unitId': '$id-unit',
      'slug': lessonId,
      'title': lessonId,
      'topicId': topicId ?? '$id.topic',
      'order': id == 'one' || id == 'base' ? 1 : 2,
      'reviewStatus': 'draft',
      'prerequisiteIds': prerequisiteId == null ? <String>[] : [prerequisiteId],
    },
  ],
  'exercises': <Object>[],
  'references': <Object>[],
});

class _MemoryBundle extends CachingAssetBundle {
  _MemoryBundle(this.values);

  final Map<String, String> values;

  @override
  Future<ByteData> load(String key) async {
    final bytes = Uint8List.fromList(utf8.encode(values[key]!));
    return ByteData.sublistView(bytes);
  }
}
