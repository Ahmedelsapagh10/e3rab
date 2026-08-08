import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({
    super.key,
    required this.onOpenLessons,
    required this.onOpenReference,
    required this.onOpenParsingLab,
  });

  final VoidCallback onOpenLessons;
  final VoidCallback onOpenReference;
  final VoidCallback onOpenParsingLab;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('اختر وجهتك', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: E3rabSpacing.medium),
      _QuickAction(
        icon: Icons.school_outlined,
        title: 'الدروس',
        subtitle: 'اختر قاعدة وابدأ التعلّم.',
        onTap: onOpenLessons,
      ),
      const SizedBox(height: E3rabSpacing.small),
      _QuickAction(
        icon: Icons.search_rounded,
        title: 'المرجع النحوي',
        subtitle: 'ابحث عن قاعدة أو مصطلح.',
        onTap: onOpenReference,
      ),
      const SizedBox(height: E3rabSpacing.small),
      _QuickAction(
        icon: Icons.science_outlined,
        title: 'معمل الإعراب',
        subtitle: 'حلّل الجملة خطوة بخطوة.',
        onTap: onOpenParsingLab,
      ),
    ],
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
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
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: ListTile(
      minTileHeight: 76,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
      onTap: onTap,
    ),
  );
}
