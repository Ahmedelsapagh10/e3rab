import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'model/grammar_reference_entry.dart';
import 'model/reference_search_result.dart';

abstract class GrammarReferenceRepository {
  Future<Either<Failure, List<GrammarReferenceEntry>>> getEntries();

  Future<Either<Failure, List<ReferenceSearchResult>>> search(String query);
}
