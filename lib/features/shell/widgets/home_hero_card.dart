import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../curriculum/data/model/lesson_model.dart';
import '../../learning/cubit/learning_cubit.dart';
import '../../learning/cubit/learning_state.dart';
import '../../learning/domain/next_learning_action.dart';
import '../../learning/navigation/lesson_phase_navigator.dart';
import '../../learning/screens/lesson_screen.dart';
import 'home_hero_support.dart';

class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({super.key, required this.state});

  final LearningState state;

  @override
  Widget build(BuildContext context) {
    final action = const NextLearningActionResolver().resolve(
      lessons: state.lessons,
      progress: state.progress,
    );
    if (state.lessons.isEmpty) {
      return const HomeCourseStatusCard(
        icon: Icons.hourglass_empty_rounded,
        title: 'المحتوى قيد التجهيز',
        message: 'لا يوجد محتوى معتمد متاح على هذا الجهاز حاليًا.',
      );
    }
    if (action.type == NextLearningActionType.courseComplete) {
      return const HomeCourseStatusCard(
        icon: Icons.workspace_premium_outlined,
        title: 'أكملت المسار المتاح',
        message: 'أحسنت. يمكنك مراجعة أي درس أو الانتقال إلى معمل الإعراب.',
      );
    }
    final lesson = action.lesson!;
    final started = state.progressFor(lesson.id) != null;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(1);
          final compact = constraints.maxWidth < 680 || textScale > 1.35;
          final content = _HeroContent(
            title: lesson.title,
            minutes: lesson.estimatedMinutes,
            started: started,
            phaseLabel: _phaseLabel(action),
            onPressed: () => _openAction(context, lesson, action),
          );
          const illustration = HomeHeroIllustration();
          return compact
              ? Column(
                  children: [
                    const SizedBox(height: 210, child: illustration),
                    content,
                  ],
                )
              : SizedBox(
                  height: 316,
                  child: Row(
                    children: [
                      Expanded(flex: 11, child: content),
                      const Expanded(flex: 10, child: illustration),
                    ],
                  ),
                );
        },
      ),
    );
  }

  void _openAction(
    BuildContext context,
    LessonModel lesson,
    NextLearningAction action,
  ) {
    if (action.phase != null) {
      LessonPhaseNavigator.open(
        context,
        lesson: lesson,
        state: state,
        phase: action.phase!,
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<LearningCubit>(),
          child: LessonScreen(lesson: lesson),
        ),
      ),
    );
  }

  String _phaseLabel(NextLearningAction action) {
    if (action.type == NextLearningActionType.remediation) {
      return 'راجع الأمثلة التي أخطأت فيها';
    }
    return switch (action.phase) {
      null => 'أكملت المسار المتاح',
      final phase => const [
        'افهم القاعدة',
        'اكتشف العلامات',
        'شاهد الإعراب',
        'جرّب معي',
        'تدرّب وحدك',
        'اختبر إتقانك',
      ][phase.index],
    };
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({
    required this.title,
    required this.minutes,
    required this.started,
    required this.phaseLabel,
    required this.onPressed,
  });

  final String title;
  final int minutes;
  final bool started;
  final String phaseLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(E3rabSpacing.xLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeroBadge(started: started),
            const SizedBox(height: E3rabSpacing.medium),
            Text(
              'خطوة صغيرة اليوم،\nفرق كبير غدًا',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                height: 1.35,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: E3rabSpacing.small),
            Text(
              '$title • $phaseLabel • $minutes دقائق',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: E3rabSpacing.large),
            FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(started ? 'متابعة الدرس' : 'ابدأ درس اليوم'),
            ),
          ],
        ),
      ),
    );
  }
}
