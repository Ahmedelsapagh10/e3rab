import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../config/routes/app_routes.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/assets_manager.dart';
import '../cubit/onboarding_cubit.dart';
import 'onboarding1.dart';
import 'onboarding2.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  Future<void> _finishOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('HomeState', true);
    await preferences.setBool('onBoarding', true);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, Routes.loginRoute);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: BlocBuilder<OnboardingCubit, OnboardingState>(
        builder: (context, state) {
          final cubit = context.read<OnboardingCubit>();
          final currentPage = cubit.currentPage.toInt();
          final isLastPage = currentPage == cubit.numPages - 1;

          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: cubit.pageController,
                        onPageChanged: cubit.onPageChanged,
                        children: const [
                          OnBoarding1(),
                          OnBoarding2(),
                          OnBoarding3(),
                        ],
                      ),
                    ),
                    SafeArea(
                      top: false,
                      minimum: const EdgeInsets.fromLTRB(24, 10, 24, 18),
                      child: Column(
                        children: [
                          SmoothPageIndicator(
                            controller: cubit.pageController,
                            count: cubit.numPages,
                            effect: const ExpandingDotsEffect(
                              activeDotColor: AppColors.primary,
                              dotColor: Color(0xFFDCE3ED),
                              dotHeight: 7,
                              dotWidth: 7,
                              expansionFactor: 3.5,
                              spacing: 6,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              onPressed: () {
                                if (isLastPage) {
                                  _finishOnboarding();
                                  return;
                                }

                                cubit.pageController.nextPage(
                                  duration: const Duration(milliseconds: 420),
                                  curve: Curves.easeOutCubic,
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                child: Text(
                                  (isLastPage ? 'start_now' : 'next').tr(),
                                  key: ValueKey(isLastPage),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                PositionedDirectional(
                  top: 0,
                  start: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        top: 10,
                        start: 16,
                      ),
                      child: Hero(
                        tag: 'app-logo',
                        transitionOnUserGestures: true,
                        child: Container(
                          width: 44,
                          height: 44,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.16),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.asset(
                              ImageAssets.appIconWithoutBG,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        top: 10,
                        end: 16,
                      ),
                      child: TextButton(
                        onPressed: _finishOnboarding,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black.withValues(alpha: 0.28),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                        ),
                        child: Text(
                          'skip'.tr(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
