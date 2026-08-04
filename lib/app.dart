import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'config/routes/app_routes.dart';
import 'config/themes/app_theme.dart';
import 'config/themes/theme_cubit.dart';
import 'core/utils/app_strings.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/on_boarding/cubit/onboarding_cubit.dart';
import 'injector.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<AuthCubit>()..restoreSession(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<OnboardingCubit>()..restore(),
        ),
        BlocProvider(create: (_) => serviceLocator<ThemeCubit>()),
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
        },
      ),
    );
  }
}
