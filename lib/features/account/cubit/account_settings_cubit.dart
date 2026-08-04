import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../progress/data/model/learning_progress_models.dart';
import '../data/account_management_repository.dart';
import 'account_settings_state.dart';

class AccountSettingsCubit extends Cubit<AccountSettingsState> {
  AccountSettingsCubit(this._repository, this.owner)
    : super(const AccountSettingsState());

  final AccountManagementRepository _repository;
  final LearningDataOwner owner;

  Future<void> resetProgress() async {
    if (state.status == AccountSettingsStatus.working) return;
    emit(const AccountSettingsState(status: AccountSettingsStatus.working));
    final result = await _repository.resetProgress(owner);
    result.fold(
      (failure) => _failure(failure, 'تعذّرت إعادة ضبط التقدم.'),
      (_) => emit(
        const AccountSettingsState(
          status: AccountSettingsStatus.progressReset,
          message: 'تمت إعادة ضبط التقدم مع الاحتفاظ بالمحفوظات والملاحظات.',
        ),
      ),
    );
  }

  Future<void> deleteAccount(String password) async {
    if (state.status == AccountSettingsStatus.working) return;
    emit(const AccountSettingsState(status: AccountSettingsStatus.working));
    final result = await _repository.deleteAccount(
      owner: owner,
      password: password,
    );
    result.fold(
      (failure) => _failure(failure, 'تعذّر حذف الحساب وبياناته.'),
      (_) => emit(
        const AccountSettingsState(
          status: AccountSettingsStatus.accountDeleted,
          message: 'تم حذف الحساب وبياناته الخاصة.',
        ),
      ),
    );
  }

  void _failure(Failure failure, String fallback) {
    final message = failure is AuthFailure ? failure.message : fallback;
    emit(
      AccountSettingsState(
        status: AccountSettingsStatus.failed,
        message: message,
      ),
    );
  }
}
