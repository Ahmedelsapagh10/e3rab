import 'package:equatable/equatable.dart';

enum SyncStatus { idle, syncing, completed, partiallyCompleted, failed }

class SyncResult extends Equatable {
  const SyncResult({
    required this.status,
    required this.uploadedOperationCount,
    required this.skippedOperationCount,
    required this.conflictIds,
  });

  final SyncStatus status;
  final int uploadedOperationCount;
  final int skippedOperationCount;
  final List<String> conflictIds;

  bool get hasConflicts => conflictIds.isNotEmpty;

  @override
  List<Object?> get props => [
    status,
    uploadedOperationCount,
    skippedOperationCount,
    conflictIds,
  ];
}
