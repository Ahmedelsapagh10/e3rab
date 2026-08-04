import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../auth/data/model/auth_user_model.dart';
import 'data_source/firestore_user_data_source.dart';
import 'model/e3rab_user_profile.dart';
import 'user_profile_repository.dart';

class FirebaseUserProfileRepository implements UserProfileRepository {
  FirebaseUserProfileRepository({FirestoreUserDataSource? dataSource})
    : _dataSource = dataSource;

  final FirestoreUserDataSource? _dataSource;

  @override
  Stream<E3rabUserProfile?> watchProfile(String uid) {
    return _dataSource?.watchProfile(uid) ?? Stream.value(null);
  }

  @override
  Future<Either<Failure, E3rabUserProfile?>> getProfile(String uid) async {
    if (_dataSource == null) return Left(_unavailable());
    try {
      return Right(await _dataSource.getProfile(uid));
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, E3rabUserProfile>> createOrRepairProfile(
    AuthUserModel user,
  ) async {
    if (_dataSource == null) return Left(_unavailable());
    try {
      return Right(await _dataSource.createOrRepairProfile(user));
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> upsertProfile(E3rabUserProfile profile) async {
    if (_dataSource == null) return Left(_unavailable());
    try {
      await _dataSource.upsertProfile(profile);
      return const Right(unit);
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProfile(String uid) async {
    if (_dataSource == null) return Left(_unavailable());
    try {
      await _dataSource.deleteProfile(uid);
      return const Right(unit);
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  FirebaseUnavailableFailure _unavailable() => FirebaseUnavailableFailure(
    message: 'مزامنة الحساب غير متاحة على هذا الجهاز.',
  );
}
