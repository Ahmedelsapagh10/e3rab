import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';

class OnBoarding1 extends StatelessWidget {
  const OnBoarding1({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingPageContent(
      icon: Icons.lightbulb_outline_rounded,
      title: 'افهم القاعدة بوضوح',
      description:
          'شرح عربي مريح يبدأ بالفكرة، ثم يوضح العلامة والسبب بخطوات مترابطة.',
    );
  }
}

class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(E3rabSpacing.xLarge),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Column(
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: E3rabBrandColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(34),
                  child: Icon(
                    icon,
                    size: 72,
                    color: E3rabBrandColors.primary,
                    semanticLabel: title,
                  ),
                ),
              ),
              const SizedBox(height: E3rabSpacing.xLarge),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: E3rabSpacing.medium),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
