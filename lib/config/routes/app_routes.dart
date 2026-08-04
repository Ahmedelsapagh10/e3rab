import 'package:flutter/material.dart';
import 'package:new_strucuture/features/forget_password/screens/forgot_password_email_screen.dart';
import 'package:new_strucuture/features/auth/screens/auth_gate.dart';
import 'package:new_strucuture/features/on_boarding/screen/onboarding_screen.dart';
import '../../core/utils/app_strings.dart';
import 'package:page_transition/page_transition.dart';
import '../../features/login/screens/login_screen.dart';

class Routes {
  static const String initialRoute = '/';
  static const String loginRoute = '/login';
  static const String mainRoute = '/main';
  static const String forgotPasswordEmailRoute = '/forgot-password/email';
  static const String onboardingPageScreenRoute = '/onboardingPageScreenRoute';
}

class AppRoutes {
  static String route = '';

  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.initialRoute:
        return MaterialPageRoute(builder: (context) => const AuthGate());

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
          child: const AuthGate(),
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
