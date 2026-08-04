import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../injector.dart';
import '../../curriculum/data/model/content_reference_model.dart';
import '../../curriculum/data/model/lesson_model.dart';
import '../../progress/data/progress_repository.dart';
import '../cubit/exercise_cubit.dart';
import '../cubit/learning_cubit.dart';
import '../cubit/learning_state.dart';
import '../widgets/lesson_content_view.dart';
import '../widgets/lesson_note_dialog.dart';
import 'exercise_screen.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.lesson});

  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LearningCubit, LearningState>(
      builder: (context, state) {
        final references = state.references
            .where((item) => lesson.referenceIds.contains(item.id))
            .toList();
        return Scaffold(
          appBar: AppBar(
            title: Text(lesson.shortTitle),
            actions: [
              IconButton(
                tooltip: 'ملاحظتي',
                onPressed: () => _editNote(context, state),
                icon: const Icon(Icons.note_alt_outlined),
              ),
              IconButton(
                tooltip: state.isBookmarked(lesson.id)
                    ? 'إزالة الحفظ'
                    : 'حفظ الدرس',
                onPressed: () =>
                    context.read<LearningCubit>().toggleBookmark(lesson),
                icon: Icon(
                  state.isBookmarked(lesson.id)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
              ),
            ],
          ),
          body: LessonContentView(
            lesson: lesson,
            references: references,
            onReference: _openReference,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _practice(context, state),
            icon: const Icon(Icons.play_arrow),
            label: const Text('ابدأ التدريب'),
          ),
        );
      },
    );
  }

  Future<void> _editNote(BuildContext context, LearningState state) async {
    final text = await showLessonNoteDialog(
      context,
      initialText: state.noteFor(lesson.id)?.text ?? '',
    );
    if (text != null && context.mounted) {
      await context.read<LearningCubit>().saveNote(lesson, text);
    }
  }

  void _practice(BuildContext context, LearningState state) {
    final learning = context.read<LearningCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => ExerciseCubit(
            progressRepository: serviceLocator<ProgressRepository>(),
            owner: learning.owner,
            lesson: lesson,
            exercises: state.exercises[lesson.id] ?? const [],
          ),
          child: ExerciseScreen(onFinished: learning.load),
        ),
      ),
    );
  }

  Future<void> _openReference(ContentReferenceModel reference) async {
    await launchUrl(
      Uri.parse(reference.url),
      mode: LaunchMode.externalApplication,
    );
  }
}
