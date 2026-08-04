import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:new_strucuture/features/main_screen/cubit/cubit.dart';
import 'package:new_strucuture/features/forget_password/cubit/cubit.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'config/routes/app_routes.dart';
import 'config/themes/app_theme.dart';
import 'config/themes/theme_cubit.dart';
import 'core/utils/app_strings.dart';
import 'package:new_strucuture/injector.dart' as injector;
import 'features/login/cubit/cubit.dart';
import 'features/splash/cubit/cubit.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => injector.serviceLocator<SplashCubit>(),
          ),
          BlocProvider(
            create: (_) => injector.serviceLocator<LoginCubit>(),
          ),
          BlocProvider(
            create: (_) => injector.serviceLocator<MainCubit>(),
          ),
          BlocProvider(
            create: (_) => injector.serviceLocator<ThemeCubit>(),
          ),
          BlocProvider(
            create: (_) => injector.serviceLocator<ForgetPasswordCubit>(),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return GetMaterialApp(
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                localizationsDelegates: context.localizationDelegates,
                debugShowCheckedModeBanner: false,
                title: AppStrings.appName,
                onGenerateRoute: AppRoutes.onGenerateRoute,
              );
            }));
  }
}
