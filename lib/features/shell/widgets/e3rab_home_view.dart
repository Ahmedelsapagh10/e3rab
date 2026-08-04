import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../learning/cubit/learning_cubit.dart';
import '../../learning/cubit/learning_state.dart';
import '../../learning/widgets/learning_status_view.dart';
import '../../progress/data/model/learning_progress_models.dart';
import '../../teacher/widgets/teacher_mode_entry_card.dart';

class E3rabHomeView extends StatelessWidget {
  const E3rabHomeView({super.key, required this.isGuest});

  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LearningCubit, LearningState>(
      builder: (context, state) => LearningStatusView(
        state: state,
        child: ListView(
          padding: const EdgeInsets.all(E3rabSpacing.large),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: E3rabReadingMetrics.maxContentWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGuest ? 'أهلًا بك في إعراب' : 'مرحبًا بعودتك إلى إعراب',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: E3rabSpacing.small),
                    const Text(
                      'افهم القاعدة، شاهدها في مثال، أعربها خطوة بخطوة، ثم طبّقها بنفسك.',
                      style: TextStyle(height: 1.7),
                    ),
                    const SizedBox(height: E3rabSpacing.large),
                    _ProgressSummary(state: state),
                    const SizedBox(height: E3rabSpacing.large),
                    const TeacherModeEntryCard(),
                    const SizedBox(height: E3rabSpacing.large),
                    Text(
                      'ابدأ من مستواك',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: E3rabSpacing.medium),
                    ...state.lessons.map(
                      (lesson) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.auto_stories_outlined),
                          title: Text(lesson.title),
                          subtitle: Text(
                            '${lesson.estimatedMinutes} دقيقة • ${lesson.exerciseIds.length} تمارين',
                          ),
                          trailing: _statusIcon(state.progressFor(lesson.id)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusIcon(LessonProgressModel? progress) {
    if (progress?.status == LessonProgressStatus.completed) {
      return const Icon(
        Icons.check_circle,
        color: Colors.green,
        semanticLabel: 'مكتمل',
      );
    }
    return const Icon(Icons.arrow_back, semanticLabel: 'متاح للتعلّم');
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({required this.state});

  final LearningState state;

  @override
  Widget build(BuildContext context) {
    final completed = state.progress
        .where((item) => item.status == LessonProgressStatus.completed)
        .length;
    final mastered = state.mastery
        .where((item) => item.state == MasteryState.mastered)
        .length;
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(E3rabSpacing.large),
        child: Wrap(
          spacing: E3rabSpacing.xLarge,
          runSpacing: E3rabSpacing.medium,
          children: [
            _Metric(
              label: 'الدروس المكتملة',
              value: '$completed/${state.lessons.length}',
            ),
            _Metric(label: 'المهارات المتقنة', value: '$mastered'),
            _Metric(
              label: 'المحفوظات',
              value:
                  '${state.bookmarks.where((item) => !item.isDeleted).length}',
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 150,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(label),
      ],
    ),
  );
}
