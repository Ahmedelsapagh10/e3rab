import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'model/auth_user_model.dart';

abstract class AuthRepository {
  bool get isAvailable;

  Stream<AuthUserModel?> authStateChanges();

  AuthUserModel? get currentUser;

  Future<Either<Failure, AuthUserModel>> createAccount({
    required String email,
    required String password,
    String? displayName,
  });

  Future<Either<Failure, AuthUserModel>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email);

  Future<Either<Failure, Unit>> signOut();
}
