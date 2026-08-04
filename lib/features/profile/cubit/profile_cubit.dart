import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/model/e3rab_user_profile.dart';
import '../data/user_profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository, this._profile)
    : super(ProfileState.fromProfile(_profile));

  final UserProfileRepository _repository;
  final E3rabUserProfile _profile;

  void selectRole(LearningRole value) => emit(state.copyWith(role: value));

  void selectCountry(String value) {
    emit(
      state.copyWith(
        countryCode: value,
        curriculumId: value == 'EG' ? 'egypt-national' : 'free-learning',
      ),
    );
  }

  void selectStage(String value) => emit(state.copyWith(stageId: value));

  void selectGrade(String value) => emit(state.copyWith(gradeId: value));

  void selectLevel(String value) => emit(state.copyWith(grammarLevel: value));

  void selectGoal(String value) => emit(state.copyWith(learningGoal: value));

  void selectDailyGoal(int value) {
    emit(state.copyWith(dailyGoalMinutes: value));
  }

  Future<void> save() async {
    if (state.status == ProfileSaveStatus.saving) return;
    emit(state.copyWith(status: ProfileSaveStatus.saving));
    final updated = _profile.copyWith(
      learningRole: state.role,
      countryCode: state.countryCode,
      curriculumId: state.curriculumId,
      curriculumVersionId: '2026-v1',
      stageId: state.stageId,
      gradeId: state.gradeId,
      grammarLevel: state.grammarLevel,
      learningGoal: state.learningGoal,
      dailyGoalMinutes: state.dailyGoalMinutes,
      onboardingCompleted: true,
      updatedAt: DateTime.now().toUtc(),
    );
    final result = await _repository.upsertProfile(updated);
    result.fold(
      (_) => emit(
        state.copyWith(
          status: ProfileSaveStatus.failure,
          message: 'تعذّر حفظ تفضيلات التعلم. حاول مرة أخرى.',
        ),
      ),
      (_) => emit(state.copyWith(status: ProfileSaveStatus.saved)),
    );
  }
}
