import 'package:equatable/equatable.dart';

enum GuestMergeStatus {
  checking,
  none,
  offer,
  merging,
  completed,
  failed,
  skipped,
}

class GuestMergeState extends Equatable {
  const GuestMergeState(this.status, {this.message});

  final GuestMergeStatus status;
  final String? message;

  @override
  List<Object?> get props => [status, message];
}
