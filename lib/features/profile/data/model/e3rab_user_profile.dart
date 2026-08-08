import 'package:equatable/equatable.dart';
import 'dart:convert';

enum LearningRole { student, teacher, parent, independentLearner }

LearningRole learningRoleFromStored(Object? value) {
  return LearningRole.values.where((role) => role.name == value).firstOrNull ??
      LearningRole.independentLearner;
}

class E3rabUserProfile extends Equatable {
  const E3rabUserProfile({
    required this.uid,
    required this.learningRole,
    required this.countryCode,
    required this.preferredLocale,
    required this.onboardingCompleted,
    required this.profileSchemaVersion,
    required this.createdAt,
    required this.updatedAt,
    this.email,
    this.displayName,
    this.photoUrl,
    this.authProviders = const [],
    this.curriculumId,
    this.curriculumVersionId,
    this.stageId,
    this.gradeId,
    this.grammarLevel,
    this.learningGoal,
    this.dailyGoalMinutes,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final List<String> authProviders;
  final LearningRole learningRole;
  final String countryCode;
  final String? curriculumId;
  final String? curriculumVersionId;
  final String? stageId;
  final String? gradeId;
  final String? grammarLevel;
  final String? learningGoal;
  final int? dailyGoalMinutes;
  final String preferredLocale;
  final bool onboardingCompleted;
  final int profileSchemaVersion;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toLocalJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'authProviders': authProviders,
    'learningRole': learningRole.name,
    'countryCode': countryCode,
    'curriculumId': curriculumId,
    'curriculumVersionId': curriculumVersionId,
    'stageId': stageId,
    'gradeId': gradeId,
    'grammarLevel': grammarLevel,
    'learningGoal': learningGoal,
    'dailyGoalMinutes': dailyGoalMinutes,
    'preferredLocale': preferredLocale,
    'onboardingCompleted': onboardingCompleted,
    'profileSchemaVersion': profileSchemaVersion,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  String toJsonString() => jsonEncode(toLocalJson());

  factory E3rabUserProfile.fromJsonString(String source) =>
      E3rabUserProfile.fromLocalJson(
        Map<String, dynamic>.from(jsonDecode(source) as Map),
      );

  factory E3rabUserProfile.fromLocalJson(Map<String, dynamic> json) {
    return E3rabUserProfile(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      authProviders: List<String>.from(json['authProviders'] as List? ?? []),
      learningRole: learningRoleFromStored(json['learningRole']),
      countryCode: json['countryCode'] as String? ?? 'GLOBAL',
      curriculumId: json['curriculumId'] as String?,
      curriculumVersionId: json['curriculumVersionId'] as String?,
      stageId: json['stageId'] as String?,
      gradeId: json['gradeId'] as String?,
      grammarLevel: json['grammarLevel'] as String?,
      learningGoal: json['learningGoal'] as String?,
      dailyGoalMinutes: (json['dailyGoalMinutes'] as num?)?.toInt(),
      preferredLocale: json['preferredLocale'] as String? ?? 'ar',
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      profileSchemaVersion:
          (json['profileSchemaVersion'] as num?)?.toInt() ?? 1,
      createdAt: _storedDate(json['createdAt']),
      updatedAt: _storedDate(json['updatedAt']),
    );
  }

  E3rabUserProfile copyWith({
    LearningRole? learningRole,
    String? countryCode,
    String? curriculumId,
    String? curriculumVersionId,
    String? stageId,
    String? gradeId,
    String? grammarLevel,
    String? learningGoal,
    int? dailyGoalMinutes,
    String? preferredLocale,
    bool? onboardingCompleted,
    DateTime? updatedAt,
  }) {
    return E3rabUserProfile(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      authProviders: authProviders,
      learningRole: learningRole ?? this.learningRole,
      countryCode: countryCode ?? this.countryCode,
      curriculumId: curriculumId ?? this.curriculumId,
      curriculumVersionId: curriculumVersionId ?? this.curriculumVersionId,
      stageId: stageId ?? this.stageId,
      gradeId: gradeId ?? this.gradeId,
      grammarLevel: grammarLevel ?? this.grammarLevel,
      learningGoal: learningGoal ?? this.learningGoal,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      preferredLocale: preferredLocale ?? this.preferredLocale,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      profileSchemaVersion: profileSchemaVersion,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    photoUrl,
    authProviders,
    learningRole,
    countryCode,
    curriculumId,
    curriculumVersionId,
    stageId,
    gradeId,
    grammarLevel,
    learningGoal,
    dailyGoalMinutes,
    preferredLocale,
    onboardingCompleted,
    profileSchemaVersion,
    createdAt,
    updatedAt,
  ];
}

DateTime _storedDate(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.utc(1970);
  return DateTime.utc(1970);
}
