import 'package:flutter_bloc/flutter_bloc.dart';

import '../../progress/data/model/learning_progress_models.dart';
import '../data/sync_repository.dart';
import 'sync_state.dart';

class SyncCubit extends Cubit<GuestMergeState> {
  SyncCubit(this._repository, this.guestOwner, this.accountOwner)
    : super(const GuestMergeState(GuestMergeStatus.checking));

  final SyncRepository _repository;
  final LearningDataOwner guestOwner;
  final LearningDataOwner accountOwner;

  Future<void> check() async {
    final sync = await _repository.syncPending(accountOwner);
    final hasData = await _repository.hasGuestData(guestOwner);
    if (hasData) {
      emit(const GuestMergeState(GuestMergeStatus.offer));
    } else if (sync.isLeft()) {
      emit(
        const GuestMergeState(
          GuestMergeStatus.failed,
          message:
              'تعذّرت مزامنة الحساب الآن. بياناتك المحلية محفوظة وسنعيد المحاولة لاحقًا.',
        ),
      );
    } else {
      emit(const GuestMergeState(GuestMergeStatus.none));
    }
  }

  Future<void> merge() async {
    emit(const GuestMergeState(GuestMergeStatus.merging));
    final result = await _repository.mergeGuestIntoAccount(
      guestOwner: guestOwner,
      accountOwner: accountOwner,
    );
    result.fold(
      (_) => emit(
        const GuestMergeState(
          GuestMergeStatus.failed,
          message:
              'تعذّر دمج تقدم الضيف. لم نحذف بياناتك ويمكن المحاولة لاحقًا.',
        ),
      ),
      (value) => emit(
        GuestMergeState(
          GuestMergeStatus.completed,
          message: value.hasConflicts
              ? 'تم الدمج مع الاحتفاظ بنسخ الملاحظات المتعارضة.'
              : 'تم دمج تقدم الضيف بنجاح.',
        ),
      ),
    );
  }

  void skip() => emit(const GuestMergeState(GuestMergeStatus.skipped));
}
