import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/assets_manager.dart';

class OnBoarding1 extends StatelessWidget {
  const OnBoarding1({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingPageContent(
      image: ImageAssets.onboardingImage1,
      titleKey: 'onboarding_one_title',
      descriptionKey: 'onboarding_one_description',
      imageAlignment: Alignment.center,
    );
  }
}

class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    required this.image,
    required this.titleKey,
    required this.descriptionKey,
    this.imageAlignment = Alignment.center,
    super.key,
  });

  final String image;
  final String titleKey;
  final String descriptionKey;
  final Alignment imageAlignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 620;
        final imageHeight = constraints.maxHeight * (compact ? 0.55 : 0.60);

        return Column(
          children: [
            SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(34),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      image,
                      fit: BoxFit.cover,
                      alignment: imageAlignment,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x40000000),
                            Colors.transparent,
                            Color(0x26000000),
                          ],
                          stops: [0, 0.42, 1],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(28, compact ? 18 : 24, 28, 8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          titleKey.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF152A48),
                            fontSize: compact ? 23 : 27,
                            height: 1.28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: compact ? 10 : 14),
                        Text(
                          descriptionKey.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF6D788A),
                            fontSize: compact ? 13 : 15,
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
