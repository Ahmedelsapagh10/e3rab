import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'model/curriculum_mapping_models.dart';

abstract class CurriculumMatrixRepository {
  Future<Either<Failure, CurriculumMatrixModel>> getCurrentMatrix();
}
