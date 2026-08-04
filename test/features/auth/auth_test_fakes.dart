import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:new_strucuture/core/error/failures.dart';
import 'package:new_strucuture/features/auth/data/auth_repository.dart';
import 'package:new_strucuture/features/auth/data/model/auth_user_model.dart';
import 'package:new_strucuture/features/profile/data/model/e3rab_user_profile.dart';
import 'package:new_strucuture/features/profile/data/user_profile_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.isAvailable = true, this.currentUser});

  @override
  final bool isAvailable;
  @override
  AuthUserModel? currentUser;
  int signInCalls = 0;
  int reauthenticateCalls = 0;
  int deleteCalls = 0;
  Completer<void>? signInGate;
  final StreamController<AuthUserModel?> controller =
      StreamController<AuthUserModel?>.broadcast();

  @override
  Stream<AuthUserModel?> authStateChanges() => controller.stream;

  @override
  Future<Either<Failure, AuthUserModel>> createAccount({
    required String email,
    required String password,
    String? displayName,
  }) async {
    currentUser = testUser.copyWith(email: email, displayName: displayName);
    return Right(currentUser!);
  }

  @override
  Future<Either<Failure, AuthUserModel>> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    await signInGate?.future;
    currentUser = testUser.copyWith(email: email);
    return Right(currentUser!);
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email) async {
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> reauthenticate(String password) async {
    reauthenticateCalls++;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> deleteCurrentAccount() async {
    deleteCalls++;
    currentUser = null;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    currentUser = null;
    return const Right(unit);
  }

  Future<void> close() => controller.close();
}

class FakeUserProfileRepository implements UserProfileRepository {
  E3rabUserProfile profile = testProfile;
  int repairCalls = 0;
  int deleteCalls = 0;

  @override
  Future<Either<Failure, E3rabUserProfile>> createOrRepairProfile(
    AuthUserModel user,
  ) async {
    repairCalls++;
    return Right(profile);
  }

  @override
  Future<Either<Failure, Unit>> deleteProfile(String uid) async {
    deleteCalls++;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, E3rabUserProfile?>> getProfile(String uid) async {
    return Right(profile);
  }

  @override
  Future<Either<Failure, Unit>> upsertProfile(E3rabUserProfile profile) async {
    this.profile = profile;
    return const Right(unit);
  }

  @override
  Stream<E3rabUserProfile?> watchProfile(String uid) => Stream.value(profile);
}

const testUser = AuthUserModel(
  uid: 'user-1',
  email: 'student@example.com',
  providerIds: ['password'],
  isEmailVerified: false,
);

final testProfile = E3rabUserProfile(
  uid: testUser.uid,
  email: testUser.email,
  authProviders: testUser.providerIds,
  learningRole: LearningRole.student,
  countryCode: 'EG',
  preferredLocale: 'ar',
  onboardingCompleted: false,
  profileSchemaVersion: 1,
  createdAt: DateTime.utc(2026, 8, 4),
  updatedAt: DateTime.utc(2026, 8, 4),
);

extension on AuthUserModel {
  AuthUserModel copyWith({String? email, String? displayName}) {
    return AuthUserModel(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl,
      providerIds: providerIds,
      isEmailVerified: isEmailVerified,
    );
  }
}
