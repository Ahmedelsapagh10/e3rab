import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../cubit/exercise_state.dart';
import 'exercise_renderer.dart';

class ExerciseQuestionView extends StatelessWidget {
  const ExerciseQuestionView({
    super.key,
    required this.state,
    required this.onSelect,
    required this.onHint,
    required this.onReveal,
    required this.onSubmit,
    required this.onNext,
  });

  final ExerciseState state;
  final ValueChanged<String> onSelect;
  final VoidCallback onHint;
  final VoidCallback onReveal;
  final VoidCallback onSubmit;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final exercise = state.current;
    return ListView(
      padding: const EdgeInsets.all(E3rabSpacing.large),
      children: [
        LinearProgressIndicator(
          value: (state.index + 1) / state.exercises.length,
          semanticsLabel: 'تقدم جلسة التدريب',
        ),
        const SizedBox(height: E3rabSpacing.medium),
        _QuestionHeader(state: state),
        const SizedBox(height: E3rabSpacing.medium),
        Text(
          exercise.prompt,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(height: 1.7),
        ),
        const SizedBox(height: E3rabSpacing.large),
        ExerciseRenderer(state: state, onSelect: onSelect),
        if (state.hintUsed && !state.submitted)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(E3rabSpacing.medium),
              child: Text('تلميح: ${exercise.hint}'),
            ),
          ),
        if (state.submitted) _Feedback(state: state),
        const SizedBox(height: E3rabSpacing.medium),
        if (!state.submitted)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: E3rabSpacing.small,
            runSpacing: E3rabSpacing.small,
            children: [
              TextButton.icon(
                onPressed: state.hintUsed ? null : onHint,
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('تلميح'),
              ),
              if (state.config.allowReveal)
                TextButton.icon(
                  onPressed: state.saving ? null : onReveal,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('اكشف الإجابة'),
                ),
              FilledButton(
                onPressed: state.selectedOptionId == null || state.saving
                    ? null
                    : onSubmit,
                child: state.saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('تحقق'),
              ),
            ],
          )
        else
          FilledButton.icon(
            onPressed: onNext,
            icon: Icon(state.isLast ? Icons.flag_outlined : Icons.arrow_back),
            label: Text(state.isLast ? 'إنهاء التدريب' : 'السؤال التالي'),
          ),
      ],
    );
  }
}

class _QuestionHeader extends StatelessWidget {
  const _QuestionHeader({required this.state});

  final ExerciseState state;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.spaceBetween,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: E3rabSpacing.medium,
    children: [
      Text('السؤال ${state.index + 1} من ${state.exercises.length}'),
      if (state.remainingSeconds case final seconds?)
        Semantics(
          liveRegion: seconds <= 30,
          label: 'الوقت المتبقي $seconds ثانية',
          child: Chip(
            avatar: const Icon(Icons.timer_outlined),
            label: Text(_duration(seconds)),
          ),
        ),
    ],
  );

  String _duration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainder = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainder';
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.state});

  final ExerciseState state;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(E3rabSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.revealed
                  ? 'تم كشف الإجابة — لا تُحتسب درجة'
                  : state.isCorrect
                  ? 'إجابة صحيحة'
                  : 'الإجابة تحتاج مراجعة',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              state.current.explanation,
              style: const TextStyle(height: 1.7),
            ),
          ],
        ),
      ),
    ),
  );
}
