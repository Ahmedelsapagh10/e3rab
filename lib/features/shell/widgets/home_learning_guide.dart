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
            'كيف تبني الإعراب؟',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: E3rabSpacing.small),
          const Text(
            'نوع الكلمة ← موقعها ← العامل ← الحالة ← العلامة ← سبب العلامة ← محل الجملة',
            style: TextStyle(height: 1.8, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: E3rabSpacing.large),
          const _GuideStep(
            icon: Icons.category_outlined,
            title: 'تعرّف',
            subtitle: 'حدّد نوع الكلمة وموقعها داخل الجملة.',
          ),
          const _GuideStep(
            icon: Icons.account_tree_outlined,
            title: 'اربط',
            subtitle: 'ابحث عن العامل الذي أثّر في الكلمة.',
          ),
          const _GuideStep(
            icon: Icons.rule_rounded,
            title: 'علّل',
            subtitle: 'اذكر الحالة والعلامة وسبب اختيار العلامة.',
          ),
          const _GuideStep(
            icon: Icons.schema_outlined,
            title: 'حدّد المحل',
            subtitle: 'إذا كان الإعراب لجملة، فحدّد محلها أو أنها لا محل لها.',
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
              backgroundColor: E3rabBrandColors.primaryContainer,
              child: Icon(icon, color: E3rabBrandColors.primary),
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
