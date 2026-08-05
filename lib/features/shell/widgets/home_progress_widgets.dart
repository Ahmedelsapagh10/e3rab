import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../learning/cubit/learning_cubit.dart';
import '../../learning/cubit/learning_state.dart';
import '../../progress/data/model/learning_progress_models.dart';

class HomeProgressSummary extends StatelessWidget {
  const HomeProgressSummary({super.key, required this.state});

  final LearningState state;

  @override
  Widget build(BuildContext context) {
    final completed = state.progress
        .where((item) => item.status == LessonProgressStatus.completed)
        .length;
    final ratio = state.lessons.isEmpty
        ? 0.0
        : completed / state.lessons.length;
    final due = state.reviews
        .where((item) => !item.dueAt.isAfter(DateTime.now().toUtc()))
        .length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 560;
        return Flex(
          direction: vertical ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: vertical ? 0 : 2,
              child: _ProgressCard(
                ratio: ratio,
                completed: completed,
                total: state.lessons.length,
              ),
            ),
            SizedBox(
              width: vertical ? 0 : E3rabSpacing.medium,
              height: vertical ? E3rabSpacing.medium : 0,
            ),
            Expanded(
              flex: vertical ? 0 : 1,
              child: _StatCard(dueReviews: due),
            ),
          ],
        );
      },
    );
  }
}

class HomeWeakSkill extends StatelessWidget {
  const HomeWeakSkill({super.key, required this.state});

  final LearningState state;

  @override
  Widget build(BuildContext context) {
    final weakest = [...state.mastery]
      ..sort((a, b) => a.score.compareTo(b.score));
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.all(E3rabSpacing.medium),
        leading: const CircleAvatar(
          backgroundColor: E3rabBrandColors.sky,
          child: Icon(
            Icons.insights_rounded,
            color: E3rabBrandColors.primaryBlue,
          ),
        ),
        title: const Text('نقطة تحتاج مراجعة'),
        subtitle: Text(
          context.read<LearningCubit>().skillLabel(weakest.first.skillId),
        ),
        trailing: Text('${(weakest.first.score * 100).round()}٪'),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.ratio,
    required this.completed,
    required this.total,
  });

  final double ratio;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(E3rabSpacing.large),
      child: Row(
        children: [
          _AnimatedProgress(ratio: ratio),
          const SizedBox(width: E3rabSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تقدمك', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: E3rabSpacing.xSmall),
                Text('$completed من $total دروس مكتملة'),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _AnimatedProgress extends StatelessWidget {
  const _AnimatedProgress({required this.ratio});

  final double ratio;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: ratio),
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 850),
    curve: Curves.easeOutCubic,
    builder: (context, value, _) => SizedBox.square(
      dimension: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 7,
            strokeCap: StrokeCap.round,
            backgroundColor: E3rabBrandColors.sky,
          ),
          Text('${(value * 100).round()}٪'),
        ],
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.dueReviews});

  final int dueReviews;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    color: Theme.of(context).colorScheme.primaryContainer,
    child: Padding(
      padding: const EdgeInsets.all(E3rabSpacing.large),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.bolt_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: E3rabSpacing.medium),
          Text(
            dueReviews == 0 ? 'رائع!' : '$dueReviews',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: E3rabSpacing.xSmall),
          Text(dueReviews == 0 ? 'لا مراجعات متأخرة' : 'مراجعات جاهزة'),
        ],
      ),
    ),
  );
}
