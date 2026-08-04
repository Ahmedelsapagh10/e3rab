import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../progress/data/model/learning_progress_models.dart';
import 'model/sync_models.dart';

abstract class SyncRepository {
  Stream<SyncStatus> watchStatus();

  Future<bool> hasGuestData(LearningDataOwner guestOwner);

  Future<Either<Failure, SyncResult>> mergeGuestIntoAccount({
    required LearningDataOwner guestOwner,
    required LearningDataOwner accountOwner,
  });

  Future<Either<Failure, SyncResult>> syncPending(
    LearningDataOwner accountOwner,
  );
}
