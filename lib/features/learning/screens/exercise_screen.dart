import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/exercise_cubit.dart';
import '../cubit/exercise_state.dart';
import '../widgets/exercise_question_view.dart';
import '../../practice/domain/practice_session_config.dart';

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
  Widget build(BuildContext context) {
    final isExam = state.config.mode == PracticeMode.lessonExam;
    return Center(
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
              state.timedOut
                  ? 'انتهى الوقت'
                  : isExam
                  ? 'أكملت الاختبار'
                  : 'أكملت التدريب',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              isExam
                  ? state.score >= .8
                        ? 'أحسنت، أتقنت الدرس: ${state.correctCount} من ${state.exercises.length}'
                        : 'أجبت ${state.correctCount} من ${state.exercises.length}. راجع الأمثلة ثم حاول مرة أخرى.'
                  : 'أكملت التدريب. يمكنك الآن الانتقال إلى اختبار الإتقان.',
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
}
