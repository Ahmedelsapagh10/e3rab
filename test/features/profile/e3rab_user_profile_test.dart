import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/profile/data/model/e3rab_user_profile.dart';

void main() {
  test('local profile serialization preserves learning preferences', () {
    final now = DateTime.utc(2026, 8, 4, 12);
    final profile = E3rabUserProfile(
      uid: 'uid-1',
      email: 'student@example.com',
      authProviders: const ['password'],
      learningRole: LearningRole.student,
      countryCode: 'EG',
      curriculumId: 'egyptian-national',
      stageId: 'preparatory',
      gradeId: 'grade-7',
      grammarLevel: 'foundation',
      dailyGoalMinutes: 15,
      preferredLocale: 'ar',
      onboardingCompleted: true,
      profileSchemaVersion: 1,
      createdAt: now,
      updatedAt: now,
    );

    final decoded = E3rabUserProfile.fromLocalJson(profile.toLocalJson());

    expect(decoded, profile);
  });
}
