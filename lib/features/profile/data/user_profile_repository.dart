import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../auth/data/model/auth_user_model.dart';
import 'model/e3rab_user_profile.dart';

abstract class UserProfileRepository {
  Stream<E3rabUserProfile?> watchProfile(String uid);

  Future<Either<Failure, E3rabUserProfile?>> getProfile(String uid);

  Future<Either<Failure, E3rabUserProfile>> createOrRepairProfile(
    AuthUserModel user,
  );

  Future<Either<Failure, Unit>> upsertProfile(E3rabUserProfile profile);

  Future<Either<Failure, Unit>> deleteProfile(String uid);
}
