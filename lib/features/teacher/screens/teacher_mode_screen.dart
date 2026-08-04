import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../curriculum/data/model/lesson_model.dart';
import '../../learning/widgets/lesson_note_dialog.dart';
import '../cubit/teacher_cubit.dart';
import '../cubit/teacher_state.dart';
import '../domain/teacher_presentation_builder.dart';
import '../widgets/teacher_delete_dialog.dart';
import '../widgets/teacher_item_dialog.dart';
import '../widgets/teacher_lessons_view.dart';
import '../widgets/teacher_workspace_view.dart';
import 'teacher_presentation_screen.dart';

class TeacherModeScreen extends StatelessWidget {
  const TeacherModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: BlocConsumer<TeacherCubit, TeacherState>(
        listenWhen: (previous, current) =>
            current.message != null && previous.message != current.message,
        listener: (context, state) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.message!))),
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text('وضع المعلم'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.school_outlined), text: 'دليل الدروس'),
                Tab(icon: Icon(Icons.folder_outlined), text: 'مساحتي'),
              ],
            ),
          ),
          body: _body(context, state),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, TeacherState state) {
    if (state.status == TeacherStatus.initial ||
        state.status == TeacherStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(semanticsLabel: 'تحميل وضع المعلم'),
      );
    }
    if (state.status == TeacherStatus.failure) {
      return Center(
        child: OutlinedButton(
          onPressed: context.read<TeacherCubit>().load,
          child: const Text('إعادة المحاولة'),
        ),
      );
    }
    return Column(
      children: [
        if (state.status == TeacherStatus.saving)
          const LinearProgressIndicator(semanticsLabel: 'حفظ مساحة المعلم'),
        Expanded(
          child: TabBarView(
            children: [
              TeacherLessonsView(
                lessons: state.lessons,
                privateNotes: state.privateNotes,
                onPresent: (lesson) => _present(context, lesson, state.lessons),
                onNote: (lesson) => _note(context, lesson, state),
              ),
              TeacherWorkspaceView(
                workspace: state.workspace,
                onCreateCollection: () => _create(context, state, false),
                onCreateRevisionSet: () => _create(context, state, true),
                onDeleteCollection: (id) =>
                    _deleteCollection(context, state, id),
                onDeleteRevisionSet: (id) =>
                    _deleteRevision(context, state, id),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _present(
    BuildContext context,
    LessonModel lesson,
    List<LessonModel> lessons,
  ) {
    final slides = const TeacherPresentationBuilder().build(lesson, lessons);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TeacherPresentationScreen(slides: slides),
      ),
    );
  }

  Future<void> _note(
    BuildContext context,
    LessonModel lesson,
    TeacherState state,
  ) async {
    final text = await showLessonNoteDialog(
      context,
      initialText: state.noteFor(lesson.id)?.text ?? '',
    );
    if (text != null && context.mounted) {
      await context.read<TeacherCubit>().savePrivateNote(lesson.id, text);
    }
  }

  Future<void> _create(
    BuildContext context,
    TeacherState state,
    bool revision,
  ) async {
    final draft = await showTeacherItemDialog(
      context,
      title: revision ? 'حزمة مراجعة جديدة' : 'مجموعة دروس جديدة',
      actionLabel: 'حفظ',
      lessons: state.lessons,
    );
    if (draft == null || !context.mounted) return;
    final cubit = context.read<TeacherCubit>();
    revision
        ? await cubit.createRevisionSet(draft.title, draft.lessonIds)
        : await cubit.createCollection(draft.title, draft.lessonIds);
  }

  Future<void> _deleteCollection(
    BuildContext context,
    TeacherState state,
    String id,
  ) async {
    final item = state.workspace.collections.firstWhere(
      (item) => item.id == id,
    );
    if (await confirmTeacherItemDeletion(context, item.title) &&
        context.mounted) {
      await context.read<TeacherCubit>().deleteCollection(id);
    }
  }

  Future<void> _deleteRevision(
    BuildContext context,
    TeacherState state,
    String id,
  ) async {
    final item = state.workspace.revisionSets.firstWhere(
      (item) => item.id == id,
    );
    if (await confirmTeacherItemDeletion(context, item.title) &&
        context.mounted) {
      await context.read<TeacherCubit>().deleteRevisionSet(id);
    }
  }
}
