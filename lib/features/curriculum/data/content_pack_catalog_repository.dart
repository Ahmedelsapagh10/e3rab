import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'model/content_pack_catalog_models.dart';

abstract class ContentPackCatalogRepository {
  Future<Either<Failure, ContentPackCatalog>> getCatalog();
}
