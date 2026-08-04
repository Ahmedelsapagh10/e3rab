import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'data_source/firestore_content_seed_data_source.dart';

abstract class ContentSeedRepository {
  Future<Either<Failure, ContentSeedWriteResult>> seedVerticalSlice();

  Future<Either<Failure, List<ContentSeedWriteResult>>> seedConfiguredPacks();
}
