import 'package:equatable/equatable.dart';

abstract class ForgetPasswordState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ForgetPasswordInitial extends ForgetPasswordState {}

class ForgetPasswordLoading extends ForgetPasswordState {}

class ForgetPasswordCodeSent extends ForgetPasswordState {
  final String email;

  ForgetPasswordCodeSent(this.email);

  @override
  List<Object?> get props => [email];
}

class ForgetPasswordCodeVerified extends ForgetPasswordState {
  final String email;
  final String code;

  ForgetPasswordCodeVerified(this.email, this.code);

  @override
  List<Object?> get props => [email, code];
}

class ForgetPasswordSuccess extends ForgetPasswordState {
  final String message;

  ForgetPasswordSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ForgetPasswordError extends ForgetPasswordState {
  final String message;

  ForgetPasswordError(this.message);

  @override
  List<Object?> get props => [message];
}
