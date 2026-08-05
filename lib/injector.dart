import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/themes/theme_cubit.dart';
import 'core/api/app_interceptors.dart';
import 'core/api/base_api_consumer.dart';
import 'core/api/dio_consumer.dart';
import 'core/firebase/firebase_platform_support.dart';
import 'core/firebase/firestore_rest_client.dart';
import 'core/init_config/initalization_config.dart';
import 'features/account/data/account_management_repository.dart';
import 'features/account/data/firebase_account_management_repository.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/data_source/firebase_auth_data_source.dart';
import 'features/auth/data/data_source/desktop_rest_auth_data_source.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/curriculum/data/curriculum_repository.dart';
import 'features/curriculum/data/grammar_coverage_repository.dart';
import 'features/curriculum/data/content_seed_repository.dart';
import 'features/curriculum/data/content_pack_catalog_repository.dart';
import 'features/curriculum/data/curriculum_matrix_repository.dart';
import 'features/curriculum/data/data_source/firestore_content_seed_data_source.dart';
import 'features/curriculum/data/data_source/local_curriculum_data_source.dart';
import 'features/curriculum/data/firebase_content_seed_repository.dart';
import 'features/curriculum/data/local_curriculum_repository.dart';
import 'features/curriculum/data/local_content_pack_catalog_repository.dart';
import 'features/curriculum/data/local_curriculum_matrix_repository.dart';
import 'features/curriculum/services/content_seeder.dart';
import 'features/on_boarding/cubit/onboarding_cubit.dart';
import 'features/on_boarding/data/onboarding_repository.dart';
import 'features/parsing/data/data_source/local_parsing_data_source.dart';
import 'features/parsing/data/grammar_analysis_service.dart';
import 'features/parsing/data/local_grammar_analysis_service.dart';
import 'features/profile/data/data_source/firestore_user_data_source.dart';
import 'features/profile/data/data_source/rest_user_profile_data_source.dart';
import 'features/profile/data/firebase_user_profile_repository.dart';
import 'features/profile/data/cached_user_profile_repository.dart';
import 'features/profile/data/user_profile_repository.dart';
import 'firebase_options.dart';
import 'features/progress/data/data_source/cloud_learning_data_source.dart';
import 'features/progress/data/data_source/firestore_learning_data_source.dart';
import 'features/progress/data/data_source/local_learning_data_source.dart';
import 'features/progress/data/data_source/rest_learning_data_source.dart';
import 'features/progress/data/local_first_progress_repository.dart';
import 'features/progress/data/progress_repository.dart';
import 'features/reference/data/grammar_reference_repository.dart';
import 'features/reference/data/local_grammar_reference_repository.dart';
import 'features/sync/data/local_first_sync_repository.dart';
import 'features/sync/data/sync_repository.dart';
import 'features/teacher/data/progress_teacher_workspace_repository.dart';
import 'features/teacher/data/teacher_workspace_repository.dart';

final serviceLocator = GetIt.instance;

Future<void> setupDependencyInjection() async {
  await serviceLocator.reset();
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton<SharedPreferences>(
    () => sharedPreferences,
  );
  serviceLocator.registerLazySingleton<BaseApiConsumer>(
    () => DioConsumer(client: serviceLocator()),
  );
  serviceLocator.registerLazySingleton(() => AppInterceptors());
  serviceLocator.registerLazySingleton(
    () => Dio(
      BaseOptions(
        contentType: 'application/x-www-form-urlencoded',
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
    ),
  );
}

Future<void> setupRepo() async {
  final usesDesktopRest = FirebasePlatformSupport.usesDesktopRest;
  final accountsAvailable = FirebasePlatformSupport.accountsAvailable(
    isInitialized: isFirebaseInitialized,
  );
  final FirebaseAuthDataSource? authDataSource = usesDesktopRest
      ? await DesktopRestAuthDataSource.create(
          client: Dio(),
          apiKey: DefaultFirebaseOptions.web.apiKey,
        )
      : accountsAvailable
      ? FirebaseAuthDataSourceImpl(FirebaseAuth.instance)
      : null;
  final desktopAuth = authDataSource is DesktopRestAuthDataSource
      ? authDataSource
      : null;
  final restClient = desktopAuth == null
      ? null
      : FirestoreRestClient(
          client: Dio(),
          projectId: DefaultFirebaseOptions.web.projectId,
          tokenProvider: desktopAuth.getValidIdToken,
        );
  final FirestoreUserDataSource? userDataSource = restClient != null
      ? RestUserProfileDataSource(restClient)
      : accountsAvailable
      ? FirestoreUserDataSourceImpl(FirebaseFirestore.instance)
      : null;
  final CloudLearningDataSource? cloudLearningDataSource = restClient != null
      ? RestLearningDataSource(restClient)
      : accountsAvailable
      ? FirestoreLearningDataSource(FirebaseFirestore.instance)
      : null;
  final ContentSeedDataSource? contentSeedDataSource = accountsAvailable
      ? FirestoreContentSeedDataSource(
          FirebaseFirestore.instance,
          FirebaseAuth.instance,
        )
      : null;
  final contentCatalogRepository = LocalContentPackCatalogRepository(
    bundle: rootBundle,
  );
  final catalog = await contentCatalogRepository.getCatalog();
  final learnerAssets = catalog.fold<List<String>>(
    (_) => const [],
    (value) => value.packs
        .where((pack) => pack.learnerEnabled)
        .map((pack) => pack.assetPath)
        .toList(growable: false),
  );
  final localCurriculumDataSource = AssetCurriculumDataSource(
    bundle: rootBundle,
    assetPaths: learnerAssets.isEmpty ? null : learnerAssets,
  );
  final localParsingDataSource = AssetParsingDataSource(bundle: rootBundle);
  final localLearningDataSource = LocalLearningDataSource(
    serviceLocator<SharedPreferences>(),
  );
  final progressRepository = LocalFirstProgressRepository(
    localLearningDataSource,
    cloud: cloudLearningDataSource,
  );

  serviceLocator.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepository(dataSource: authDataSource),
  );
  serviceLocator.registerLazySingleton<UserProfileRepository>(
    () => CachedUserProfileRepository(
      FirebaseUserProfileRepository(dataSource: userDataSource),
      serviceLocator<SharedPreferences>(),
    ),
  );
  serviceLocator.registerLazySingleton<LocalCurriculumDataSource>(
    () => localCurriculumDataSource,
  );
  serviceLocator.registerLazySingleton<CurriculumRepository>(
    () => LocalCurriculumRepository(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<GrammarCoverageRepository>(
    () => LocalGrammarCoverageRepository(bundle: rootBundle),
  );
  serviceLocator.registerLazySingleton<ContentPackCatalogRepository>(
    () => contentCatalogRepository,
  );
  serviceLocator.registerLazySingleton<CurriculumMatrixRepository>(
    () => LocalCurriculumMatrixRepository(bundle: rootBundle),
  );
  serviceLocator.registerLazySingleton<LocalParsingDataSource>(
    () => localParsingDataSource,
  );
  serviceLocator.registerLazySingleton<GrammarAnalysisService>(
    () => LocalGrammarAnalysisService(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<GrammarReferenceRepository>(
    () => LocalGrammarReferenceRepository(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<ContentSeedRepository>(
    () => FirebaseContentSeedRepository(
      bundle: rootBundle,
      dataSource: contentSeedDataSource,
      catalogRepository: serviceLocator(),
    ),
  );
  serviceLocator.registerLazySingleton(() => ContentSeeder(serviceLocator()));
  serviceLocator.registerLazySingleton<LocalLearningDataSource>(
    () => localLearningDataSource,
  );
  serviceLocator.registerLazySingleton<ProgressRepository>(
    () => progressRepository,
  );
  serviceLocator.registerLazySingleton<AccountManagementRepository>(
    () => FirebaseAccountManagementRepository(
      serviceLocator(),
      serviceLocator(),
      progressRepository,
      localLearningDataSource,
    ),
  );
  serviceLocator.registerLazySingleton<SyncRepository>(
    () => LocalFirstSyncRepository(
      localLearningDataSource,
      progressRepository,
      cloud: cloudLearningDataSource,
    ),
  );
  serviceLocator.registerLazySingleton<TeacherWorkspaceRepository>(
    () => ProgressTeacherWorkspaceRepository(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => OnboardingRepository(serviceLocator()),
  );
}

Future<void> setupCubit() async {
  serviceLocator.registerFactory(
    () => AuthCubit(serviceLocator(), serviceLocator()),
  );
  serviceLocator.registerFactory(() => OnboardingCubit(serviceLocator()));
  serviceLocator.registerFactory(() => ThemeCubit());
}
