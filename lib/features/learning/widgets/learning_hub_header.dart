import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';

class LearningHubHeader extends StatelessWidget {
  const LearningHubHeader({
    super.key,
    required this.onOpenReference,
    required this.onOpenParsingLab,
  });

  final VoidCallback onOpenReference;
  final VoidCallback onOpenParsingLab;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    color: Theme.of(context).colorScheme.primaryContainer,
    child: Padding(
      padding: const EdgeInsets.all(E3rabSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(E3rabRadii.medium),
                ),
                child: const Icon(Icons.route_rounded, color: Colors.white),
              ),
              const SizedBox(width: E3rabSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مسارك في النحو واضح',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: E3rabSpacing.xSmall),
                    Text(
                      'ابدأ بالدرس المناسب، واستعن بالأدوات عندما تحتاج إجابة سريعة.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: E3rabSpacing.large),
          LayoutBuilder(
            builder: (context, constraints) {
              final vertical =
                  constraints.maxWidth < 520 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.35;
              return Flex(
                direction: vertical ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: vertical ? 0 : 1,
                    child: _LearningTool(
                      icon: Icons.search_rounded,
                      title: 'المرجع النحوي',
                      subtitle: 'ابحث عن قاعدة أو مصطلح',
                      onTap: onOpenReference,
                    ),
                  ),
                  SizedBox(
                    width: vertical ? 0 : E3rabSpacing.medium,
                    height: vertical ? E3rabSpacing.small : 0,
                  ),
                  Expanded(
                    flex: vertical ? 0 : 1,
                    child: _LearningTool(
                      icon: Icons.science_outlined,
                      title: 'معمل الإعراب',
                      subtitle: 'حلّل الجملة خطوة بخطوة',
                      onTap: onOpenParsingLab,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _LearningTool extends StatelessWidget {
  const _LearningTool({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(E3rabRadii.medium),
    child: InkWell(
      borderRadius: BorderRadius.circular(E3rabRadii.medium),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(E3rabSpacing.medium),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: E3rabSpacing.small),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_rounded, size: 20),
          ],
        ),
      ),
    ),
  );
}
