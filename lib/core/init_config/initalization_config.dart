import 'package:new_strucuture/app_bloc_observer.dart';
import 'package:new_strucuture/core/exports.dart';
import 'package:new_strucuture/core/notification_services/notification_service.dart';
import 'package:new_strucuture/core/utils/connectivity/connectivity.dart';
import 'package:new_strucuture/core/utils/system_ui.dart';
import 'package:new_strucuture/firebase_options.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_strucuture/injector.dart' as injector;
import '../preferences/preferences.dart';

bool isFirebaseInitialized = false;

Future<void> initializationClass() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isFirebaseConfigured = false;
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    if (options.apiKey.isNotEmpty && options.appId.isNotEmpty) {
      isFirebaseConfigured = true;
    }
  } catch (_) {
    debugPrint('Firebase options are not configured for this platform.');
  }

  if (isFirebaseConfigured) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      isFirebaseInitialized = true;
    } catch (_) {
      debugPrint(
        'Firebase initialization failed; guest mode remains available.',
      );
    }
  } else {
    debugPrint("Firebase is not configured or setup. Skipping initialization.");
  }

  NotificationService notificationService = NotificationService();
  await EasyLocalization.ensureInitialized();
  await ScreenUtil.ensureScreenSize();

  prefs = await SharedPreferences.getInstance();
  SystemUiStyle.overlayStyle();
  await ConnectivityHandler().checkConnection();

  if (isFirebaseInitialized) {
    try {
      await notificationService.initialize();
    } catch (_) {
      debugPrint('Notifications are unavailable; app startup will continue.');
    }
  }

  await injector.setupDependencyInjection();
  await injector.setupRepo();
  await injector.setupCubit();
  Bloc.observer = AppBlocObserver();

  await ConnectivityHandler().checkConnection();
}
