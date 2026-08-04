import 'package:dio/dio.dart';
import 'package:new_strucuture/config/themes/theme_cubit.dart';
import 'package:new_strucuture/features/login/cubit/cubit.dart';
import 'package:new_strucuture/features/login/data/login_repo.dart';
import 'package:new_strucuture/features/main_screen/cubit/cubit.dart';
import 'package:new_strucuture/features/splash/cubit/cubit.dart';
import 'package:new_strucuture/features/forget_password/cubit/cubit.dart';
import 'package:new_strucuture/features/forget_password/data/forget_password_repo.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/api/app_interceptors.dart';
import 'core/api/base_api_consumer.dart';
import 'core/api/dio_consumer.dart';
import 'features/main_screen/data/main_repo.dart';

final serviceLocator = GetIt.instance;
Future<void> setupCubit() async {
  serviceLocator.registerFactory(
    () => SplashCubit(),
  );

  serviceLocator.registerFactory(
    () => LoginCubit(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => MainCubit(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => ThemeCubit(),
  );
  serviceLocator.registerFactory(
    () => ForgetPasswordCubit(
      serviceLocator(),
    ),
  );
}

Future<void> setupRepo() async {
  serviceLocator.registerLazySingleton(() => LoginRepo(serviceLocator()));
  serviceLocator.registerLazySingleton(() => MainRepo(serviceLocator()));
  serviceLocator.registerLazySingleton(() => ForgetPasswordRepo(serviceLocator()));
}

Future<void> setupDependencyInjection() async {
  await serviceLocator.reset();
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton(() => sharedPreferences);

  ///! (dio)
  serviceLocator.registerLazySingleton<BaseApiConsumer>(
      () => DioConsumer(client: serviceLocator()));
  serviceLocator.registerLazySingleton(() => AppInterceptors());

  // Dio
  serviceLocator.registerLazySingleton(
    () => Dio(
      BaseOptions(
        contentType: "application/x-www-form-urlencoded",
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
    ),
  );
}
