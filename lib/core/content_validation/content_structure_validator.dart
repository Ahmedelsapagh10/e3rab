part of 'content_validation_service.dart';

extension _ContentStructureValidator on ContentValidationService {
  Map<String, dynamic> _mapAt(
    Map<String, dynamic> source,
    String key,
    List<ValidationIssue> issues,
  ) {
    final value = source[key];
    if (value is Map<String, dynamic>) return value;
    issues.add(
      ValidationIssue(
        code: 'invalid_map',
        message: '$key must be an object.',
        path: key,
      ),
    );
    return const {};
  }

  List<Map<String, dynamic>> _mapsAt(
    Map<String, dynamic> source,
    String key,
    List<ValidationIssue> issues,
  ) {
    final value = source[key];
    if (value is! List) {
      issues.add(
        ValidationIssue(
          code: 'invalid_list',
          message: '$key must be a list.',
          path: key,
        ),
      );
      return const [];
    }
    return value.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  Set<String> _uniqueIds(
    List<Map<String, dynamic>> items,
    String path,
    List<ValidationIssue> issues,
  ) {
    final ids = <String>{};
    for (var index = 0; index < items.length; index++) {
      final id = items[index]['id'];
      if (id is! String || id.trim().isEmpty) {
        issues.add(
          ValidationIssue(
            code: 'missing_id',
            message: 'Every item must have a non-empty string ID.',
            path: '$path[$index].id',
          ),
        );
      } else if (!ids.add(id)) {
        issues.add(
          ValidationIssue(
            code: 'duplicate_id',
            message: 'Duplicate ID: $id.',
            path: '$path[$index].id',
          ),
        );
      }
    }
    return ids;
  }

  void _checkUniqueSlugs(
    List<Map<String, dynamic>> lessons,
    List<ValidationIssue> issues,
  ) {
    final slugs = <String>{};
    for (var index = 0; index < lessons.length; index++) {
      final slug = lessons[index]['slug'];
      if (slug is! String || slug.trim().isEmpty || !slugs.add(slug)) {
        issues.add(
          ValidationIssue(
            code: 'invalid_lesson_slug',
            message: 'Lesson slugs must be non-empty and unique.',
            path: 'lessons[$index].slug',
          ),
        );
      }
    }
  }

  void _requireReference(
    Map<String, dynamic> item,
    String field,
    Set<String> validIds,
    String path,
    List<ValidationIssue> issues,
  ) {
    final id = item[field];
    if (id is! String || !validIds.contains(id)) {
      issues.add(
        ValidationIssue(
          code: 'invalid_reference',
          message: '$field must reference an existing entity.',
          path: '$path.${item['id'] ?? 'unknown'}.$field',
        ),
      );
    }
  }

  void _requireFields(
    Map<String, dynamic> item,
    List<String> fields,
    String path,
    List<ValidationIssue> issues,
  ) {
    for (final field in fields) {
      if (!item.containsKey(field) || item[field] == null) {
        issues.add(
          ValidationIssue(
            code: 'missing_field',
            message: 'Required field is missing: $field.',
            path: '$path.$field',
          ),
        );
      }
    }
  }

  void _rejectHtml(
    Map<String, dynamic> item,
    String field,
    String path,
    List<ValidationIssue> issues,
  ) {
    final value = item[field];
    if (value is String && RegExp(r'<[^>]+>').hasMatch(value)) {
      issues.add(
        ValidationIssue(
          code: 'html_not_allowed',
          message: 'Raw HTML is not allowed in content fields.',
          path: '$path.${item['id']}.$field',
        ),
      );
    }
  }

  void _validatePrerequisiteGraph(
    List<Map<String, dynamic>> lessons,
    Set<String> lessonIds,
    Set<String> externalPrerequisiteIds,
    List<ValidationIssue> issues,
  ) {
    final knownIds = {...lessonIds, ...externalPrerequisiteIds};
    final graph = <String, List<String>>{};
    for (final lesson in lessons) {
      final id = lesson['id'];
      if (id is! String) continue;
      final prerequisites = _stringList(lesson['prerequisiteIds']);
      graph[id] = prerequisites;
      if (!knownIds.containsAll(prerequisites)) {
        issues.add(
          ValidationIssue(
            code: 'unknown_prerequisite',
            message: 'A prerequisite references an unknown lesson.',
            path: 'lessons.$id.prerequisiteIds',
          ),
        );
      }
    }
    final visiting = <String>{};
    final visited = <String>{};
    bool visit(String id) {
      if (visiting.contains(id)) return false;
      if (visited.contains(id)) return true;
      visiting.add(id);
      for (final dependency in graph[id] ?? const []) {
        if (graph.containsKey(dependency) && !visit(dependency)) return false;
      }
      visiting.remove(id);
      visited.add(id);
      return true;
    }

    for (final id in graph.keys) {
      if (!visit(id)) {
        issues.add(
          ValidationIssue(
            code: 'cyclic_prerequisite',
            message: 'Lesson prerequisites must not contain a cycle.',
            path: 'lessons.$id.prerequisiteIds',
          ),
        );
        break;
      }
    }
  }
}
