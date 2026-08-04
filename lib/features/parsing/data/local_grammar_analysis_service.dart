import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../curriculum/data/model/content_review_status.dart';
import 'data_source/local_parsing_data_source.dart';
import 'grammar_analysis_service.dart';
import 'model/parsing_models.dart';

class LocalGrammarAnalysisService implements GrammarAnalysisService {
  LocalGrammarAnalysisService(this._dataSource);

  final LocalParsingDataSource _dataSource;

  @override
  Future<Either<Failure, List<ParsingSampleModel>>> getSamples({
    bool includeDrafts = false,
  }) async {
    try {
      final samples = await _dataSource.loadSamples();
      return Right(
        samples
            .where((sample) {
              if (sample.reviewStatus == ContentReviewStatus.archived) {
                return false;
              }
              return includeDrafts || sample.isApproved;
            })
            .toList(growable: false),
      );
    } catch (_) {
      return Left(CacheFailure());
    }
  }
}
