import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../auth/data/auth_repository.dart';
import '../../profile/data/user_profile_repository.dart';
import '../../progress/data/data_source/local_learning_data_source.dart';
import '../../progress/data/model/learning_progress_models.dart';
import '../../progress/data/progress_repository.dart';
import 'account_management_repository.dart';

class FirebaseAccountManagementRepository
    implements AccountManagementRepository {
  FirebaseAccountManagementRepository(
    this._auth,
    this._profiles,
    this._progress,
    this._local,
  );

  final AuthRepository _auth;
  final UserProfileRepository _profiles;
  final ProgressRepository _progress;
  final LocalLearningDataSource _local;

  @override
  Future<Either<Failure, Unit>> resetProgress(LearningDataOwner owner) =>
      _progress.resetProgress(owner);

  @override
  Future<Either<Failure, Unit>> deleteAccount({
    required LearningDataOwner owner,
    required String password,
  }) async {
    if (owner.type != LearningDataOwnerType.account) {
      return Left(AuthFailure(code: 'guest', message: 'لا يوجد حساب لحذفه.'));
    }
    final reauthentication = password.isEmpty
        ? await _auth.reauthenticateWithProvider()
        : await _auth.reauthenticate(password);
    final reauthenticationFailure = reauthentication.fold<Failure?>(
      (failure) => failure,
      (_) => null,
    );
    if (reauthenticationFailure != null) return Left(reauthenticationFailure);

    final profileDeletion = await _profiles.deleteProfile(owner.id);
    final profileFailure = profileDeletion.fold<Failure?>(
      (failure) => failure,
      (_) => null,
    );
    if (profileFailure != null) return Left(profileFailure);

    final authDeletion = await _auth.deleteCurrentAccount();
    final authFailure = authDeletion.fold<Failure?>(
      (failure) => failure,
      (_) => null,
    );
    if (authFailure != null) return Left(authFailure);

    try {
      await _local.clear(owner);
    } catch (_) {
      // The remote account is already deleted; no retry can restore it.
    }
    return const Right(unit);
  }
}
