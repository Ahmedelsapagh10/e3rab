import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../curriculum/data/model/lesson_model.dart';
import '../../learning/cubit/learning_cubit.dart';
import '../../learning/cubit/learning_state.dart';
import '../../learning/screens/lesson_screen.dart';
import '../../progress/data/model/learning_progress_models.dart';

class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({super.key, required this.state});

  final LearningState state;

  @override
  Widget build(BuildContext context) {
    final lesson = state.lessons.firstWhere(
      (item) =>
          state.progressFor(item.id)?.status != LessonProgressStatus.completed,
      orElse: () => state.lessons.first,
    );
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
            onPressed: () => _openLesson(context, lesson),
          );
          const illustration = _HeroIllustration();
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

  void _openLesson(BuildContext context, LessonModel lesson) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<LearningCubit>(),
          child: LessonScreen(lesson: lesson),
        ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({
    required this.title,
    required this.minutes,
    required this.started,
    required this.onPressed,
  });

  final String title;
  final int minutes;
  final bool started;
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
            _HeroBadge(started: started),
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
              '$title • $minutes دقائق',
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

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.started});

  final bool started;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: E3rabBrandColors.sky,
      borderRadius: BorderRadius.circular(E3rabRadii.large),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Text(
        started ? 'جاهز للمتابعة' : 'درس اليوم',
        style: const TextStyle(
          color: E3rabBrandColors.navy,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

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
