import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../progress/data/model/learning_progress_models.dart';

class LessonDocumentedLabel extends StatelessWidget {
  const LessonDocumentedLabel({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: E3rabSpacing.xSmall,
    runSpacing: E3rabSpacing.xSmall,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: const [
      Icon(
        Icons.verified_outlined,
        size: 18,
        color: E3rabBrandColors.primaryBlue,
      ),
      Text('موثّق بالمراجع', style: TextStyle(fontWeight: FontWeight.w600)),
    ],
  );
}

class LessonCardFooter extends StatelessWidget {
  const LessonCardFooter({
    super.key,
    required this.minutes,
    required this.exerciseCount,
    required this.status,
  });

  final int minutes;
  final int exerciseCount;
  final LessonProgressStatus status;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.35;
    final metadata = Wrap(
      spacing: E3rabSpacing.medium,
      runSpacing: E3rabSpacing.small,
      children: [
        _Meta(icon: Icons.schedule_rounded, text: '$minutes د'),
        _Meta(icon: Icons.edit_note_rounded, text: '$exerciseCount تمارين'),
      ],
    );
    final action = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _statusLabel,
          style: TextStyle(
            color: status == LessonProgressStatus.completed
                ? E3rabBrandColors.success
                : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: E3rabSpacing.xSmall),
        const Icon(Icons.arrow_back_rounded, size: 20),
      ],
    );
    if (largeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          metadata,
          const SizedBox(height: E3rabSpacing.small),
          action,
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: metadata),
        action,
      ],
    );
  }

  String get _statusLabel => switch (status) {
    LessonProgressStatus.completed => 'مكتمل',
    LessonProgressStatus.inProgress => 'متابعة',
    LessonProgressStatus.notStarted => 'ابدأ',
  };
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: E3rabSpacing.xSmall),
      Text(text, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}
