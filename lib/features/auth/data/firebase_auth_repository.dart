import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/error/failures.dart';
import 'auth_repository.dart';
import 'data_source/firebase_auth_data_source.dart';
import 'firebase_auth_error_mapper.dart';
import 'model/auth_user_model.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuthDataSource? dataSource})
    : _dataSource = dataSource;

  final FirebaseAuthDataSource? _dataSource;

  @override
  bool get isAvailable => _dataSource != null;

  @override
  Stream<AuthUserModel?> authStateChanges() {
    return _dataSource?.authStateChanges() ?? Stream.value(null);
  }

  @override
  AuthUserModel? get currentUser => _dataSource?.currentUser;

  @override
  Future<Either<Failure, AuthUserModel>> createAccount({
    required String email,
    required String password,
    String? displayName,
  }) {
    return _runUser(
      () => _dataSource!.createAccount(
        email: email,
        password: password,
        displayName: displayName,
      ),
    );
  }

  @override
  Future<Either<Failure, AuthUserModel>> signIn({
    required String email,
    required String password,
  }) {
    return _runUser(
      () => _dataSource!.signIn(email: email, password: password),
    );
  }

  @override
  Future<Either<Failure, AuthUserModel>> signInWithGoogle() {
    return _runUser(() => _dataSource!.signInWithGoogle());
  }

  @override
  Future<Either<Failure, AuthUserModel>> signInWithApple() {
    return _runUser(() => _dataSource!.signInWithApple());
  }

  @override
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email) {
    return _runUnit(() => _dataSource!.sendPasswordResetEmail(email));
  }

  @override
  Future<Either<Failure, Unit>> reauthenticate(String password) {
    return _runUnit(() => _dataSource!.reauthenticate(password));
  }

  @override
  Future<Either<Failure, Unit>> reauthenticateWithProvider() {
    return _runUnit(() => _dataSource!.reauthenticateWithProvider());
  }

  @override
  Future<Either<Failure, Unit>> deleteCurrentAccount() {
    return _runUnit(() => _dataSource!.deleteCurrentAccount());
  }

  @override
  Future<Either<Failure, Unit>> signOut() {
    return _runUnit(() => _dataSource!.signOut());
  }

  Future<Either<Failure, AuthUserModel>> _runUser(
    Future<AuthUserModel> Function() operation,
  ) async {
    if (!isAvailable) return Left(_unavailable());
    try {
      return Right(await operation());
    } on FirebaseAuthException catch (error) {
      return Left(
        AuthFailure(
          code: error.code,
          message: FirebaseAuthErrorMapper.message(error),
        ),
      );
    } catch (error) {
      return Left(
        AuthFailure(
          code: 'unknown',
          message: FirebaseAuthErrorMapper.message(error),
        ),
      );
    }
  }

  Future<Either<Failure, Unit>> _runUnit(
    Future<void> Function() operation,
  ) async {
    if (!isAvailable) return Left(_unavailable());
    try {
      await operation();
      return const Right(unit);
    } on FirebaseAuthException catch (error) {
      return Left(
        AuthFailure(
          code: error.code,
          message: FirebaseAuthErrorMapper.message(error),
        ),
      );
    } catch (error) {
      return Left(
        AuthFailure(
          code: 'unknown',
          message: FirebaseAuthErrorMapper.message(error),
        ),
      );
    }
  }

  FirebaseUnavailableFailure _unavailable() => FirebaseUnavailableFailure(
    message: 'تسجيل الدخول غير متاح الآن. تحقق من الاتصال ثم أعد المحاولة.',
  );
}
