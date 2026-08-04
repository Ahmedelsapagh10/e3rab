import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:new_strucuture/core/utils/assets_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static final Uri _portfolioUrl = Uri.parse(
    'https://elsapagh.octopusteam.net/',
  );

  late Timer _timer;

  Future<void> _openPortfolio() async {
    await launchUrl(_portfolioUrl, mode: LaunchMode.externalApplication);
  }

  void _goNext() {
    _getStoreUser();
  }

  Future<void> _startDelay() async {
    _timer = Timer(const Duration(seconds: 8, milliseconds: 500), () {
      _goNext();
    });
  }

  Future<void> _getStoreUser() async {
    Navigator.pushReplacementNamed(context, Routes.loginRoute);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('onBoarding') == true) {
      //! un comment this case u make user mode
      //! and store it in locl and want use it
      //!  to check user make login before or not
      //  if (prefs.getString('user') != null) {
      //     Navigator.pushReplacementNamed(context, Routes.mainRoute);
      //   } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.loginRoute,
        ModalRoute.withName(Routes.initialRoute),
      );
      //   }
    } else {
      Navigator.pushReplacementNamed(context, Routes.onboardingPageScreenRoute);
    }
  }

  @override
  void initState() {
    super.initState();
    // context.read<SplashCubit>().getAdsOfApp();

    _startDelay();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Hero(
              tag: 'logo',
              child: Lottie.asset(
                ImageAssets.splashAnimation,
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 24,
            left: 0,
            child: SafeArea(
              top: false,
              child: Center(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextButton(
                    onPressed: _openPortfolio,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Connect',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    //   },
    // );
  }
}
