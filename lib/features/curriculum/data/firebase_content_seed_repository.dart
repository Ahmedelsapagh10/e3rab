import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

import '../../../core/content_validation/content_validation_service.dart';
import '../../../core/error/failures.dart';
import 'content_seed_repository.dart';
import 'content_pack_catalog_repository.dart';
import 'data_source/firestore_content_seed_data_source.dart';
import 'local_content_pack_catalog_repository.dart';
import 'model/content_pack_catalog_models.dart';

class FirebaseContentSeedRepository implements ContentSeedRepository {
  FirebaseContentSeedRepository({
    required AssetBundle bundle,
    required ContentSeedDataSource? dataSource,
    ContentPackCatalogRepository? catalogRepository,
    ContentValidationService validator = const ContentValidationService(),
    this.assetPath = 'assets/content/e3rab_vertical_slice_v1.json',
  }) : _bundle = bundle,
       _dataSource = dataSource,
       _catalogRepository =
           catalogRepository ??
           LocalContentPackCatalogRepository(bundle: bundle),
       _validator = validator;

  final AssetBundle _bundle;
  final ContentSeedDataSource? _dataSource;
  final ContentPackCatalogRepository _catalogRepository;
  final ContentValidationService _validator;
  final String assetPath;

  @override
  Future<Either<Failure, ContentSeedWriteResult>> seedVerticalSlice() async {
    if (_dataSource == null) return Left(ServerFailure());
    return _seedAsset(assetPath);
  }

  @override
  Future<Either<Failure, List<ContentSeedWriteResult>>>
  seedConfiguredPacks() async {
    if (_dataSource == null) return Left(ServerFailure());
    final catalogResult = await _catalogRepository.getCatalog();
    Failure? catalogFailure;
    ContentPackCatalog? catalog;
    catalogResult.fold(
      (failure) => catalogFailure = failure,
      (value) => catalog = value,
    );
    if (catalogFailure != null) return Left(catalogFailure!);
    final entries = catalog!.packs.where((entry) => entry.seedEnabled);
    final results = <ContentSeedWriteResult>[];
    for (final entry in entries) {
      final result = await _seedAsset(entry.assetPath);
      Failure? seedFailure;
      result.fold((failure) => seedFailure = failure, results.add);
      if (seedFailure != null) return Left(seedFailure!);
    }
    return Right(results);
  }

  Future<Either<Failure, ContentSeedWriteResult>> _seedAsset(
    String path,
  ) async {
    final dataSource = _dataSource;
    if (dataSource == null) return Left(ServerFailure());
    try {
      final raw = await _bundle.loadString(path);
      final pack = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final manifest = Map<String, dynamic>.from(pack['manifest'] as Map);
      manifest['checksum'] = sha256.convert(utf8.encode(raw)).toString();
      pack['manifest'] = manifest;
      final validation = _validator.validate(pack);
      if (!validation.isValid) return Left(CacheFailure());
      return Right(await dataSource.seed(pack));
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}
