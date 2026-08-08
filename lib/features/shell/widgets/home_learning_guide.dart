import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';

class HomeLearningGuide extends StatelessWidget {
  const HomeLearningGuide({super.key});

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(E3rabSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تعلّم بثلاث خطوات',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: E3rabSpacing.large),
          const _GuideStep(
            icon: Icons.menu_book_outlined,
            title: 'افهم',
            subtitle: 'اقرأ القاعدة بكلمات بسيطة.',
          ),
          const _GuideStep(
            icon: Icons.lightbulb_outline_rounded,
            title: 'شاهد',
            subtitle: 'تأمل الأمثلة المشروحة.',
          ),
          const _GuideStep(
            icon: Icons.edit_note_rounded,
            title: 'طبّق',
            subtitle: 'تدرّب ثم اختبر فهمك بهدوء.',
            showLine: false,
          ),
        ],
      ),
    ),
  );
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showLine = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool showLine;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              backgroundColor: E3rabBrandColors.sky,
              child: Icon(icon, color: E3rabBrandColors.primaryBlue),
            ),
            if (showLine)
              Expanded(
                child: Container(
                  width: 2,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
          ],
        ),
        const SizedBox(width: E3rabSpacing.medium),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: E3rabSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: E3rabSpacing.xSmall),
                Text(subtitle, style: const TextStyle(height: 1.6)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
