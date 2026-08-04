import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'model/parsing_models.dart';

abstract class GrammarAnalysisService {
  Future<Either<Failure, List<ParsingSampleModel>>> getSamples({
    bool includeDrafts = false,
  });
}
