import 'package:equatable/equatable.dart';

class TeacherCollectionModel extends Equatable {
  const TeacherCollectionModel({
    required this.id,
    required this.title,
    required this.lessonIds,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final List<String> lessonIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'lessonIds': lessonIds,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  factory TeacherCollectionModel.fromJson(Map<String, dynamic> json) =>
      TeacherCollectionModel(
        id: json['id'] as String,
        title: json['title'] as String,
        lessonIds: List<String>.from(json['lessonIds'] as List),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  TeacherCollectionModel asConflictCopy(String noteId) =>
      TeacherCollectionModel(
        id: noteId,
        title: '$title (نسخة تعارض)',
        lessonIds: lessonIds,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  @override
  List<Object?> get props => [id, title, lessonIds, createdAt, updatedAt];
}

class TeacherRevisionSetModel extends Equatable {
  const TeacherRevisionSetModel({
    required this.id,
    required this.title,
    required this.lessonIds,
    required this.exerciseIds,
    required this.createdAt,
  });

  final String id;
  final String title;
  final List<String> lessonIds;
  final List<String> exerciseIds;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'lessonIds': lessonIds,
    'exerciseIds': exerciseIds,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };

  factory TeacherRevisionSetModel.fromJson(Map<String, dynamic> json) =>
      TeacherRevisionSetModel(
        id: json['id'] as String,
        title: json['title'] as String,
        lessonIds: List<String>.from(json['lessonIds'] as List),
        exerciseIds: List<String>.from(json['exerciseIds'] as List),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  TeacherRevisionSetModel asConflictCopy(String noteId) =>
      TeacherRevisionSetModel(
        id: noteId,
        title: '$title (نسخة تعارض)',
        lessonIds: lessonIds,
        exerciseIds: exerciseIds,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, title, lessonIds, exerciseIds, createdAt];
}

class TeacherWorkspaceModel extends Equatable {
  const TeacherWorkspaceModel({
    this.collections = const [],
    this.revisionSets = const [],
    this.schemaVersion = 1,
  });

  final List<TeacherCollectionModel> collections;
  final List<TeacherRevisionSetModel> revisionSets;
  final int schemaVersion;

  Map<String, Object?> toJson() => {
    'collections': collections.map((item) => item.toJson()).toList(),
    'revisionSets': revisionSets.map((item) => item.toJson()).toList(),
    'schemaVersion': schemaVersion,
  };

  factory TeacherWorkspaceModel.fromJson(Map<String, dynamic> json) =>
      TeacherWorkspaceModel(
        collections: (json['collections'] as List? ?? const [])
            .map(
              (item) => TeacherCollectionModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(),
        revisionSets: (json['revisionSets'] as List? ?? const [])
            .map(
              (item) => TeacherRevisionSetModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(),
        schemaVersion: json['schemaVersion'] as int? ?? 1,
      );

  TeacherWorkspaceModel copyWith({
    List<TeacherCollectionModel>? collections,
    List<TeacherRevisionSetModel>? revisionSets,
  }) => TeacherWorkspaceModel(
    collections: collections ?? this.collections,
    revisionSets: revisionSets ?? this.revisionSets,
    schemaVersion: schemaVersion,
  );

  @override
  List<Object?> get props => [collections, revisionSets, schemaVersion];
}
