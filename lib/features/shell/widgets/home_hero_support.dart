import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';

class HomeHeroBadge extends StatelessWidget {
  const HomeHeroBadge({super.key, required this.started});

  final bool started;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: E3rabBrandColors.primaryContainer,
      borderRadius: BorderRadius.circular(E3rabRadii.large),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Text(
        started ? 'جاهز للمتابعة' : 'درس اليوم',
        style: const TextStyle(
          color: E3rabBrandColors.heading,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class HomeHeroIllustration extends StatelessWidget {
  const HomeHeroIllustration({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'متعلم يدرس النحو بخطوات بسيطة',
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 190),
      child: Image.asset(
        'assets/images/grammar_learning_hero_v1.png',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        alignment: Alignment.centerLeft,
        excludeFromSemantics: true,
      ),
    ),
  );
}

class HomeCourseStatusCard extends StatelessWidget {
  const HomeCourseStatusCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(E3rabSpacing.xLarge),
      child: Column(
        children: [
          Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: E3rabSpacing.medium),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: E3rabSpacing.small),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
