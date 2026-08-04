import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../progress/data/model/learning_progress_models.dart';

abstract class AccountManagementRepository {
  Future<Either<Failure, Unit>> resetProgress(LearningDataOwner owner);

  Future<Either<Failure, Unit>> deleteAccount({
    required LearningDataOwner owner,
    required String password,
  });
}
