import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../learning/cubit/learning_state.dart';

class HomeTodayPlan extends StatelessWidget {
  const HomeTodayPlan({super.key, required this.state});

  final LearningState state;

  @override
  Widget build(BuildContext context) {
    final due = state.reviews
        .where((item) => !item.dueAt.isAfter(DateTime.now().toUtc()))
        .length;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(E3rabSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: E3rabSpacing.medium,
              runSpacing: E3rabSpacing.small,
              children: [
                Text(
                  'خطة اليوم',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  due == 0 ? '15 دقيقة خفيفة' : '$due مراجعات مستحقة',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: E3rabSpacing.large),
            LayoutBuilder(
              builder: (context, constraints) => _PlanSteps(
                vertical: constraints.maxWidth < 580,
                dueReviews: due,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanSteps extends StatelessWidget {
  const _PlanSteps({required this.vertical, required this.dueReviews});

  final bool vertical;
  final int dueReviews;

  @override
  Widget build(BuildContext context) {
    final items = [
      const _PlanStep(
        number: '1',
        icon: Icons.auto_stories_outlined,
        title: 'تعلّم',
        subtitle: 'قاعدة واحدة',
      ),
      const _PlanStep(
        number: '2',
        icon: Icons.task_alt_rounded,
        title: 'طبّق',
        subtitle: 'تدريب موجّه',
      ),
      _PlanStep(
        number: '3',
        icon: Icons.replay_rounded,
        title: 'راجع',
        subtitle: dueReviews == 0 ? 'أنت محدّث' : '$dueReviews مستحقة',
      ),
    ];
    return Flex(
      direction: vertical ? Axis.vertical : Axis.horizontal,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          Expanded(flex: vertical ? 0 : 1, child: items[index]),
          if (index < items.length - 1) _PlanConnector(vertical: vertical),
        ],
      ],
    );
  }
}

class _PlanStep extends StatelessWidget {
  const _PlanStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String number;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: E3rabBrandColors.sky,
            child: Icon(icon, color: E3rabBrandColors.primaryBlue),
          ),
          Positioned(
            right: -2,
            top: -5,
            child: CircleAvatar(
              radius: 9,
              backgroundColor: E3rabBrandColors.primaryBlue,
              child: Text(
                number,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(width: E3rabSpacing.small),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    ],
  );
}

class _PlanConnector extends StatelessWidget {
  const _PlanConnector({required this.vertical});

  final bool vertical;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: vertical ? 48 : E3rabSpacing.medium,
    height: vertical ? E3rabSpacing.medium : 2,
    child: Center(
      child: Container(
        width: vertical ? 2 : double.infinity,
        height: vertical ? double.infinity : 2,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    ),
  );
}
