import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../profile/data/user_profile_repository.dart';
import '../data/auth_repository.dart';
import '../data/model/auth_user_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository, this._profileRepository)
    : super(const AuthInitial());

  final AuthRepository _authRepository;
  final UserProfileRepository _profileRepository;
  StreamSubscription<AuthUserModel?>? _authSubscription;
  bool _isSubmitting = false;

  bool get accountsAvailable => _authRepository.isAvailable;

  Future<void> restoreSession() async {
    emit(const AuthRestoring());
    if (!accountsAvailable) {
      emit(
        const AuthUnavailable(
          'الحسابات غير متاحة على هذا الجهاز حاليًا. يمكنك المتابعة كضيف.',
        ),
      );
      return;
    }

    await _authSubscription?.cancel();
    _authSubscription = _authRepository.authStateChanges().listen(
      _onAuthStateChanged,
    );
    final user = _authRepository.currentUser;
    if (user == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    await _completeAuthentication(user);
  }

  Future<void> signIn({required String email, required String password}) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    emit(const AuthSubmitting('signIn'));
    final result = await _authRepository.signIn(
      email: email.trim().toLowerCase(),
      password: password,
    );
    await result.fold(_emitFailure, _completeAuthentication);
    _isSubmitting = false;
  }

  Future<void> createAccount({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    emit(const AuthSubmitting('createAccount'));
    final result = await _authRepository.createAccount(
      email: email.trim().toLowerCase(),
      password: password,
      displayName: displayName?.trim(),
    );
    await result.fold(_emitFailure, _completeAuthentication);
    _isSubmitting = false;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    emit(const AuthSubmitting('passwordReset'));
    final result = await _authRepository.sendPasswordResetEmail(
      email.trim().toLowerCase(),
    );
    result.fold((failure) {
      if (failure is AuthFailure && failure.code == 'user-not-found') {
        _emitResetSent();
      } else {
        _emitFailure(failure);
      }
    }, (_) => _emitResetSent());
    _isSubmitting = false;
  }

  void enterGuest() => emit(const AuthGuest());

  Future<void> signOut() async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    emit(const AuthSubmitting('signOut'));
    final result = await _authRepository.signOut();
    result.fold(_emitFailure, (_) => emit(const AuthUnauthenticated()));
    _isSubmitting = false;
  }

  Future<void> refreshProfile() async {
    final user = _authRepository.currentUser;
    if (user != null) await _completeAuthentication(user);
  }

  Future<void> _completeAuthentication(AuthUserModel user) async {
    final result = await _profileRepository.createOrRepairProfile(user);
    result.fold(
      (_) => emit(
        const AuthOperationFailure(
          'تم تسجيل الحساب، لكن تعذّر تجهيز ملف التعلم. حاول مرة أخرى.',
        ),
      ),
      (profile) => emit(AuthAuthenticated(user: user, profile: profile)),
    );
  }

  void _onAuthStateChanged(AuthUserModel? user) {
    if (_isSubmitting) return;
    if (user == null) {
      if (state is AuthAuthenticated) emit(const AuthUnauthenticated());
      return;
    }
    unawaited(_completeAuthentication(user));
  }

  Future<void> _emitFailure(Failure failure) async {
    final message = switch (failure) {
      AuthFailure authFailure => authFailure.message,
      FirebaseUnavailableFailure unavailable => unavailable.message,
      _ => 'تعذّر إتمام العملية الآن. حاول مرة أخرى.',
    };
    emit(AuthOperationFailure(message));
  }

  void _emitResetSent() {
    emit(
      const AuthPasswordResetSent(
        'إذا كان البريد مسجلًا فستصلك رسالة إعادة التعيين خلال دقائق.',
      ),
    );
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
