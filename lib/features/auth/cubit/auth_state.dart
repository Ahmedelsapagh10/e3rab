import 'package:equatable/equatable.dart';

import '../../profile/data/model/e3rab_user_profile.dart';
import '../data/model/auth_user_model.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthRestoring extends AuthState {
  const AuthRestoring();
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthGuest extends AuthState {
  const AuthGuest();
}

final class AuthUnavailable extends AuthState {
  const AuthUnavailable(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class AuthSubmitting extends AuthState {
  const AuthSubmitting(this.action);

  final String action;

  @override
  List<Object?> get props => [action];
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user, required this.profile});

  final AuthUserModel user;
  final E3rabUserProfile profile;

  bool get needsOnboarding => !profile.onboardingCompleted;

  @override
  List<Object?> get props => [user, profile];
}

final class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class AuthOperationFailure extends AuthState {
  const AuthOperationFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
