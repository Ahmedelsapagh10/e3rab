import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app.dart';
import 'core/init_config/initalization_config.dart';
import 'core/utils/restart_app_class.dart';
import 'features/curriculum/services/content_seeder.dart';
import 'injector.dart';

void main() async {
  await initializationClass();
  final contentSeedStatus = await serviceLocator<ContentSeeder>()
      .seedIfEnabled();
  if (contentSeedStatus != ContentSeedStatus.disabled) {
    debugPrint('E3rab content seed status: ${contentSeedStatus.name}');
  }
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar', ''), Locale('en', '')],
      path: 'assets/lang',
      saveLocale: true,
      startLocale: const Locale('ar', ''),
      fallbackLocale: const Locale('ar', ''),
      child: HotRestartController(
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (ctx, child) {
            return const MyApp();
          },
        ),
      ),
    ),
  );
}
