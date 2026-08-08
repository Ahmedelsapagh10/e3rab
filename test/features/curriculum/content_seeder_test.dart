import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/error/failures.dart';
import 'package:new_strucuture/features/curriculum/data/content_seed_repository.dart';
import 'package:new_strucuture/features/curriculum/data/data_source/firestore_content_seed_data_source.dart';
import 'package:new_strucuture/features/curriculum/data/firebase_content_seed_repository.dart';
import 'package:new_strucuture/features/curriculum/data/local_content_pack_catalog_repository.dart';
import 'package:new_strucuture/features/curriculum/services/content_seeder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every configured pack is validated and passed to the seeder', () async {
    final dataSource = _RecordingDataSource();
    final repository = FirebaseContentSeedRepository(
      bundle: rootBundle,
      dataSource: dataSource,
    );

    final result = await repository.seedConfiguredPacks();
    final catalogResult = await LocalContentPackCatalogRepository(
      bundle: rootBundle,
    ).getCatalog();
    final catalog = catalogResult.getOrElse(
      () => throw StateError('Expected content catalog.'),
    );
    final seededPacks = catalog.packs.where((pack) => pack.seedEnabled);

    expect(result.getOrElse(() => const []), [
      for (final _ in seededPacks) ContentSeedWriteResult.seeded,
    ]);
    expect(dataSource.packs, hasLength(seededPacks.length));
    for (final pack in dataSource.packs) {
      final lessons = pack['lessons'] as List;
      final exercises = pack['exercises'] as List;
      expect(lessons, isNotEmpty);
      expect(exercises.length, greaterThanOrEqualTo(lessons.length * 10));
      final manifest = pack['manifest'] as Map<String, dynamic>;
      expect(manifest['checksum'], matches(RegExp(r'^[a-f0-9]{64}$')));
    }
  });

  test(
    'seeder is a no-op unless both debug and explicit flag are enabled',
    () async {
      final repository = _FakeSeedRepository();
      final seeder = ContentSeeder(repository, enabled: false, debugMode: true);

      expect(await seeder.seedIfEnabled(), ContentSeedStatus.disabled);
      expect(repository.calls, 0);
    },
  );

  test('enabled seeder maps idempotent write results', () async {
    final repository = _FakeSeedRepository();
    final seeder = ContentSeeder(repository, enabled: true, debugMode: true);

    expect(await seeder.seedIfEnabled(), ContentSeedStatus.seeded);
    repository.result = const Right(ContentSeedWriteResult.unchanged);
    expect(await seeder.seedIfEnabled(), ContentSeedStatus.unchanged);
  });
}

class _RecordingDataSource implements ContentSeedDataSource {
  final packs = <Map<String, dynamic>>[];

  @override
  Future<ContentSeedWriteResult> seed(Map<String, dynamic> pack) async {
    packs.add(pack);
    return ContentSeedWriteResult.seeded;
  }
}

class _FakeSeedRepository implements ContentSeedRepository {
  Either<Failure, ContentSeedWriteResult> result = const Right(
    ContentSeedWriteResult.seeded,
  );
  int calls = 0;

  @override
  Future<Either<Failure, List<ContentSeedWriteResult>>>
  seedConfiguredPacks() async {
    calls++;
    return result.map((value) => [value]);
  }

  @override
  Future<Either<Failure, ContentSeedWriteResult>> seedVerticalSlice() async {
    return result;
  }
}
