import 'package:equatable/equatable.dart';

enum AccountSettingsStatus {
  idle,
  working,
  progressReset,
  accountDeleted,
  failed,
}

class AccountSettingsState extends Equatable {
  const AccountSettingsState({
    this.status = AccountSettingsStatus.idle,
    this.message,
  });

  final AccountSettingsStatus status;
  final String? message;

  @override
  List<Object?> get props => [status, message];
}
