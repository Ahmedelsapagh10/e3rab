import 'package:equatable/equatable.dart';

import '../../curriculum/data/model/lesson_model.dart';
import '../../progress/data/model/learning_support_models.dart';
import '../data/model/teacher_workspace_models.dart';

enum TeacherStatus { initial, loading, ready, saving, failure }

class TeacherState extends Equatable {
  const TeacherState({
    this.status = TeacherStatus.initial,
    this.lessons = const [],
    this.workspace = const TeacherWorkspaceModel(),
    this.privateNotes = const [],
    this.message,
  });

  final TeacherStatus status;
  final List<LessonModel> lessons;
  final TeacherWorkspaceModel workspace;
  final List<LearningNoteModel> privateNotes;
  final String? message;

  LearningNoteModel? noteFor(String lessonId) => privateNotes
      .where((note) => note.targetId == lessonId && note.deletedAt == null)
      .firstOrNull;

  TeacherState copyWith({
    TeacherStatus? status,
    List<LessonModel>? lessons,
    TeacherWorkspaceModel? workspace,
    List<LearningNoteModel>? privateNotes,
    String? message,
    bool clearMessage = false,
  }) => TeacherState(
    status: status ?? this.status,
    lessons: lessons ?? this.lessons,
    workspace: workspace ?? this.workspace,
    privateNotes: privateNotes ?? this.privateNotes,
    message: clearMessage ? null : message ?? this.message,
  );

  @override
  List<Object?> get props => [
    status,
    lessons,
    workspace,
    privateNotes,
    message,
  ];
}
