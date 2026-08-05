import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/error/failures.dart';
import '../../auth/data/model/auth_user_model.dart';
import 'model/e3rab_user_profile.dart';
import 'user_profile_repository.dart';

class CachedUserProfileRepository implements UserProfileRepository {
  CachedUserProfileRepository(this._remote, this._preferences);

  final UserProfileRepository _remote;
  final SharedPreferences _preferences;

  String _key(String uid) => 'e3rab_cached_profile_$uid';

  @override
  Future<Either<Failure, E3rabUserProfile>> createOrRepairProfile(
    AuthUserModel user,
  ) async {
    final result = await _remote.createOrRepairProfile(user);
    return result.fold<Future<Either<Failure, E3rabUserProfile>>>(
      (failure) async {
        final cached = _read(user.uid);
        return cached == null ? Left(failure) : Right(cached);
      },
      (profile) async {
        await _write(profile);
        return Right(profile);
      },
    );
  }

  @override
  Future<Either<Failure, E3rabUserProfile?>> getProfile(String uid) async {
    final result = await _remote.getProfile(uid);
    return result.fold<Future<Either<Failure, E3rabUserProfile?>>>(
      (_) async => Right(_read(uid)),
      (profile) async {
        if (profile != null) await _write(profile);
        return Right(profile);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> upsertProfile(E3rabUserProfile profile) async {
    await _write(profile);
    return _remote.upsertProfile(profile);
  }

  @override
  Stream<E3rabUserProfile?> watchProfile(String uid) async* {
    yield (await getProfile(uid)).getOrElse(() => _read(uid));
  }

  @override
  Future<Either<Failure, Unit>> deleteProfile(String uid) async {
    final result = await _remote.deleteProfile(uid);
    if (result.isRight()) await _preferences.remove(_key(uid));
    return result;
  }

  E3rabUserProfile? _read(String uid) {
    final source = _preferences.getString(_key(uid));
    return source == null ? null : E3rabUserProfile.fromJsonString(source);
  }

  Future<void> _write(E3rabUserProfile profile) {
    return _preferences.setString(_key(profile.uid), profile.toJsonString());
  }
}
