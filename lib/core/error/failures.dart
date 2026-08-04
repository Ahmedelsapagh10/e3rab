import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failure {}

class CacheFailure extends Failure {}

class AuthFailure extends Failure {
  AuthFailure({required this.code, required this.message});

  final String code;
  final String message;

  @override
  List<Object?> get props => [code, message];
}

class FirebaseUnavailableFailure extends Failure {
  FirebaseUnavailableFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
