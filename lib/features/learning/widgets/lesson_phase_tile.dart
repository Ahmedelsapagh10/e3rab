import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';

class LessonPhaseTile extends StatelessWidget {
  const LessonPhaseTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.recommended = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool recommended;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: recommended ? scheme.primaryContainer : scheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(E3rabRadii.medium),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(E3rabSpacing.medium),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: recommended ? scheme.primary : E3rabBrandColors.sky,
                  borderRadius: BorderRadius.circular(E3rabRadii.medium),
                ),
                child: Icon(
                  icon,
                  color: recommended ? Colors.white : scheme.primary,
                ),
              ),
              const SizedBox(width: E3rabSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (recommended)
                      Text(
                        'الخطوة المقترحة',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: E3rabSpacing.xSmall),
                    Text(subtitle, style: const TextStyle(height: 1.5)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
