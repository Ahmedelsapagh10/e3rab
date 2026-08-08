import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../../core/utils/assets_manager.dart';
import '../cubit/onboarding_cubit.dart';
import 'onboarding1.dart';
import 'onboarding2.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final cubit = context.read<OnboardingCubit>();
        final isLastPage = cubit.currentPage == OnboardingCubit.numPages - 1;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                ImageAssets.appIconWithoutBG,
                semanticLabel: 'شعار إعراب',
              ),
            ),
            actions: [
              TextButton(onPressed: cubit.complete, child: const Text('تخطي')),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: cubit.pageController,
                  onPageChanged: cubit.onPageChanged,
                  children: const [OnBoarding1(), OnBoarding2(), OnBoarding3()],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(E3rabSpacing.large),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 580),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: SmoothPageIndicator(
                              controller: cubit.pageController,
                              count: OnboardingCubit.numPages,
                              effect: const WormEffect(
                                activeDotColor: E3rabBrandColors.primary,
                                dotColor: E3rabBrandColors.primaryContainer,
                                dotHeight: 8,
                                dotWidth: 8,
                              ),
                            ),
                          ),
                          const SizedBox(height: E3rabSpacing.large),
                          FilledButton(
                            onPressed: () => _next(context, cubit, isLastPage),
                            child: Text(isLastPage ? 'ابدأ الآن' : 'متابعة'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _next(
    BuildContext context,
    OnboardingCubit cubit,
    bool isLastPage,
  ) async {
    if (isLastPage) {
      await cubit.complete();
      return;
    }
    await cubit.pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }
}
