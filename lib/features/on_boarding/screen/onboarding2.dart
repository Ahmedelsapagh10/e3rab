import 'package:flutter/material.dart';

import '../../../core/utils/assets_manager.dart';
import 'onboarding1.dart';

class OnBoarding2 extends StatelessWidget {
  const OnBoarding2({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingPageContent(
      image: ImageAssets.onboardingImage2,
      titleKey: 'onboarding_two_title',
      descriptionKey: 'onboarding_two_description',
      imageAlignment: Alignment.center,
    );
  }
}

class OnBoarding3 extends StatelessWidget {
  const OnBoarding3({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingPageContent(
      image: ImageAssets.onboardingImage3,
      titleKey: 'onboarding_three_title',
      descriptionKey: 'onboarding_three_description',
      imageAlignment: Alignment.center,
    );
  }
}
