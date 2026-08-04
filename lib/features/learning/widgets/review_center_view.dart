import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../../injector.dart';
import '../../curriculum/data/model/exercise_model.dart';
import '../../practice/domain/practice_session_config.dart';
import '../../progress/data/model/learning_progress_models.dart';
import '../../progress/data/progress_repository.dart';
import '../cubit/exercise_cubit.dart';
import '../cubit/learning_cubit.dart';
import '../cubit/learning_state.dart';
import '../screens/exercise_screen.dart';
import 'learning_status_view.dart';

class ReviewCenterView extends StatelessWidget {
  const ReviewCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LearningCubit, LearningState>(
      builder: (context, state) {
        final learning = context.read<LearningCubit>();
        final due = state.reviews
            .where((item) => !item.dueAt.isAfter(DateTime.now().toUtc()))
            .length;
        final reviewQueue = learning.reviewQueue();
        final cumulative = learning.cumulativeQueue();
        return LearningStatusView(
          state: state,
          child: ListView(
            padding: const EdgeInsets.all(E3rabSpacing.large),
            children: [
              Text(
                'مركز التدريب',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: E3rabSpacing.small),
              const Text(
                'تدريب موجّه لنقاط الضعف، أو اختبار تراكمي مع بديل بلا مؤقت.',
              ),
              const SizedBox(height: E3rabSpacing.large),
              _PracticeActions(
                dueCount: due,
                reviewEnabled: reviewQueue.isNotEmpty,
                cumulativeEnabled: cumulative.isNotEmpty,
                onReview: () => _open(
                  context,
                  reviewQueue,
                  const PracticeSessionConfig.review(),
                ),
                onUntimed: () => _open(
                  context,
                  cumulative,
                  const PracticeSessionConfig.review(),
                ),
                onTimed: () => _open(
                  context,
                  cumulative,
                  const PracticeSessionConfig.timed(),
                ),
              ),
              const SizedBox(height: E3rabSpacing.large),
              if (state.mastery.isEmpty)
                const _EmptyReview()
              else ...[
                Text(
                  'مستوى المهارات',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: E3rabSpacing.medium),
                ...state.mastery.map(
                  (item) => Card(
                    child: ListTile(
                      leading: Icon(_icon(item.state)),
                      title: Text(learning.skillLabel(item.skillId)),
                      subtitle: LinearProgressIndicator(
                        value: item.score,
                        semanticsLabel: 'نسبة إتقان المهارة',
                      ),
                      trailing: Text('${(item.score * 100).round()}٪'),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _open(
    BuildContext context,
    List<ExerciseModel> exercises,
    PracticeSessionConfig config,
  ) {
    final learning = context.read<LearningCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => ExerciseCubit(
            progressRepository: serviceLocator<ProgressRepository>(),
            owner: learning.owner,
            exercises: exercises,
            config: config,
          ),
          child: ExerciseScreen(onFinished: learning.load),
        ),
      ),
    );
  }

  IconData _icon(MasteryState state) => switch (state) {
    MasteryState.newSkill => Icons.fiber_new_outlined,
    MasteryState.learning => Icons.trending_up,
    MasteryState.needsReview => Icons.schedule,
    MasteryState.mastered => Icons.verified_outlined,
  };
}

class _PracticeActions extends StatelessWidget {
  const _PracticeActions({
    required this.dueCount,
    required this.reviewEnabled,
    required this.cumulativeEnabled,
    required this.onReview,
    required this.onUntimed,
    required this.onTimed,
  });

  final int dueCount;
  final bool reviewEnabled;
  final bool cumulativeEnabled;
  final VoidCallback onReview;
  final VoidCallback onUntimed;
  final VoidCallback onTimed;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(E3rabSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'مستحق الآن: $dueCount',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: E3rabSpacing.medium),
          FilledButton.icon(
            onPressed: reviewEnabled ? onReview : null,
            icon: const Icon(Icons.replay_outlined),
            label: const Text('راجع نقاط الضعف'),
          ),
          const SizedBox(height: E3rabSpacing.small),
          OutlinedButton.icon(
            onPressed: cumulativeEnabled ? onTimed : null,
            icon: const Icon(Icons.timer_outlined),
            label: const Text('اختبار تراكمي — ٥ دقائق'),
          ),
          TextButton.icon(
            onPressed: cumulativeEnabled ? onUntimed : null,
            icon: const Icon(Icons.accessibility_new_outlined),
            label: const Text('نفس الاختبار بلا مؤقت'),
          ),
        ],
      ),
    ),
  );
}

class _EmptyReview extends StatelessWidget {
  const _EmptyReview();

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(E3rabSpacing.large),
      child: Text('أكمل تمرينًا أولًا لنحسب إتقانك ونجهز مراجعتك الموجّهة.'),
    ),
  );
}
