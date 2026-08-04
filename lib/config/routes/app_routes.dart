import 'package:flutter/material.dart';
import 'package:new_strucuture/features/forget_password/screens/forgot_password_email_screen.dart';
import 'package:new_strucuture/features/forget_password/screens/forgot_password_otp_screen.dart';
import 'package:new_strucuture/features/forget_password/screens/forgot_password_reset_screen.dart';
import 'package:new_strucuture/features/main_screen/screens/main_screen.dart';
import 'package:new_strucuture/features/on_boarding/screen/onboarding_screen.dart';
import 'package:new_strucuture/features/splash/screens/splash_screen.dart';
import '../../core/utils/app_strings.dart';
import 'package:page_transition/page_transition.dart';
import '../../features/login/screens/login_screen.dart';

class Routes {
  static const String initialRoute = '/';
  static const String loginRoute = '/login';
  static const String mainRoute = '/main';
  static const String forgotPasswordEmailRoute = '/forgot-password/email';
  static const String forgotPasswordOtpRoute = '/forgot-password/otp';
  static const String forgotPasswordResetRoute = '/forgot-password/reset';
  static const String onboardingPageScreenRoute = '/onboardingPageScreenRoute';
}

class AppRoutes {
  static String route = '';

  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.initialRoute:
        return MaterialPageRoute(builder: (context) => const SplashScreen());

      // case Routes.detailsRoute:
      //   final service = settings.arguments as ServicesModel;
      //   return MaterialPageRoute(
      //     // Extract the service model argument from the settings arguments map
      //
      //     builder: (context) => Details(service: service),
      //   );
      //
      case Routes.loginRoute:
        return PageTransition(
          child: const LoginScreen(),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );

      case Routes.onboardingPageScreenRoute:
        return PageTransition(
          child: const OnBoardingScreen(),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );
      case Routes.mainRoute:
        return PageTransition(
          child: const MainScreen(),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );
      case Routes.forgotPasswordEmailRoute:
        return PageTransition(
          child: const ForgotPasswordEmailScreen(),
          type: PageTransitionType.rightToLeft,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 400),
        );
      case Routes.forgotPasswordOtpRoute:
        return PageTransition(
          child: const ForgotPasswordOtpScreen(),
          type: PageTransitionType.rightToLeft,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 400),
          settings: settings,
        );
      case Routes.forgotPasswordResetRoute:
        return PageTransition(
          child: const ForgotPasswordResetScreen(),
          type: PageTransitionType.rightToLeft,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 400),
          settings: settings,
        );
      //
      // case Routes.resultOfLessonExam:
      //   ResponseOfApplyLessonExmamData model =
      //       settings.arguments as ResponseOfApplyLessonExmamData;
      //   return PageTransition(
      //     child: ResultExamLessonScreen(model: model),
      //     type: PageTransitionType.fade,
      //     alignment: Alignment.center,
      //     duration: const Duration(milliseconds: 800),
      //   );

      default:
        return undefinedRoute();
    }
  }

  static Route<dynamic> undefinedRoute() {
    return MaterialPageRoute(
      builder: (context) =>
          const Scaffold(body: Center(child: Text(AppStrings.noRouteFound))),
    );
  }
}
