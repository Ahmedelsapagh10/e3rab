import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/forget_password_repo.dart';
import 'state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  final ForgetPasswordRepo repo;

  ForgetPasswordCubit(this.repo) : super(ForgetPasswordInitial());

  Future<void> sendCode(String emailOrPhone) async {
    emit(ForgetPasswordLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    emit(ForgetPasswordCodeSent(emailOrPhone));
  }

  Future<void> verifyCode(String emailOrPhone, String code) async {
    emit(ForgetPasswordLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    emit(ForgetPasswordCodeVerified(emailOrPhone, code));
  }

  Future<void> resetPassword(
    String emailOrPhone,
    String code,
    String newPassword,
    String confirmPassword,
  ) async {
    emit(ForgetPasswordLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    emit(ForgetPasswordSuccess("Password has been reset successfully."));
  }

  void reset() {
    emit(ForgetPasswordInitial());
  }
}
