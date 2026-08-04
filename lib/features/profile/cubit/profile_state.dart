import 'package:equatable/equatable.dart';

import '../data/model/e3rab_user_profile.dart';

enum ProfileSaveStatus { editing, saving, saved, failure }

class ProfileState extends Equatable {
  const ProfileState({
    required this.role,
    required this.countryCode,
    required this.curriculumId,
    required this.stageId,
    required this.gradeId,
    required this.grammarLevel,
    required this.learningGoal,
    required this.dailyGoalMinutes,
    this.status = ProfileSaveStatus.editing,
    this.message,
  });

  factory ProfileState.fromProfile(E3rabUserProfile profile) {
    return ProfileState(
      role: profile.learningRole,
      countryCode: profile.countryCode,
      curriculumId: profile.curriculumId ?? 'egypt-national',
      stageId: profile.stageId ?? 'foundation',
      gradeId: profile.gradeId ?? 'general',
      grammarLevel: profile.grammarLevel ?? 'beginner',
      learningGoal: profile.learningGoal ?? 'schoolSuccess',
      dailyGoalMinutes: profile.dailyGoalMinutes ?? 15,
    );
  }

  final LearningRole role;
  final String countryCode;
  final String curriculumId;
  final String stageId;
  final String gradeId;
  final String grammarLevel;
  final String learningGoal;
  final int dailyGoalMinutes;
  final ProfileSaveStatus status;
  final String? message;

  ProfileState copyWith({
    LearningRole? role,
    String? countryCode,
    String? curriculumId,
    String? stageId,
    String? gradeId,
    String? grammarLevel,
    String? learningGoal,
    int? dailyGoalMinutes,
    ProfileSaveStatus? status,
    String? message,
  }) {
    return ProfileState(
      role: role ?? this.role,
      countryCode: countryCode ?? this.countryCode,
      curriculumId: curriculumId ?? this.curriculumId,
      stageId: stageId ?? this.stageId,
      gradeId: gradeId ?? this.gradeId,
      grammarLevel: grammarLevel ?? this.grammarLevel,
      learningGoal: learningGoal ?? this.learningGoal,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      status: status ?? this.status,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    role,
    countryCode,
    curriculumId,
    stageId,
    gradeId,
    grammarLevel,
    learningGoal,
    dailyGoalMinutes,
    status,
    message,
  ];
}
