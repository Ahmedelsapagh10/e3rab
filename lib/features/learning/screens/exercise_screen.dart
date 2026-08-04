import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/exercise_cubit.dart';
import '../cubit/exercise_state.dart';
import '../widgets/exercise_question_view.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key, required this.onFinished});

  final Future<void> Function() onFinished;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExerciseCubit, ExerciseState>(
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: Text(state.config.title)),
        body: state.exercises.isEmpty
            ? const Center(child: Text('لا توجد تمارين متاحة لهذه الجلسة.'))
            : state.completed
            ? _CompletionView(state: state, onClose: () => _close(context))
            : ExerciseQuestionView(
                state: state,
                onSelect: context.read<ExerciseCubit>().selectAnswer,
                onHint: context.read<ExerciseCubit>().showHint,
                onReveal: context.read<ExerciseCubit>().revealAnswer,
                onSubmit: context.read<ExerciseCubit>().submit,
                onNext: context.read<ExerciseCubit>().next,
              ),
      ),
    );
  }

  Future<void> _close(BuildContext context) async {
    await onFinished();
    if (context.mounted) Navigator.pop(context);
  }
}

class _CompletionView extends StatelessWidget {
  const _CompletionView({required this.state, required this.onClose});

  final ExerciseState state;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            state.timedOut
                ? Icons.timer_off_outlined
                : Icons.emoji_events_outlined,
            size: 72,
          ),
          const SizedBox(height: 16),
          Text(
            state.timedOut ? 'انتهى الوقت' : 'أكملت التدريب',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text('الإجابات الصحيحة ${(state.score * 100).round()}٪'),
          Text('الدرجة الموزونة ${(state.weightedScore * 100).round()}٪'),
          const SizedBox(height: 8),
          const Text(
            'تراعي الدرجة الموزونة التلميحات والمحاولات السابقة وكشف الإجابة.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onClose,
            child: const Text('العودة إلى التعلّم'),
          ),
        ],
      ),
    ),
  );
}
