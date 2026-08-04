import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../cubit/learning_cubit.dart';
import '../cubit/learning_state.dart';
import '../screens/lesson_screen.dart';
import 'learning_status_view.dart';
import 'lesson_card.dart';

class LearningCatalogView extends StatelessWidget {
  const LearningCatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LearningCubit, LearningState>(
      builder: (context, state) => LearningStatusView(
        state: state,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1024
                ? 3
                : constraints.maxWidth >= 600
                ? 2
                : 1;
            return GridView.builder(
              padding: const EdgeInsets.all(E3rabSpacing.large),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: E3rabSpacing.medium,
                mainAxisSpacing: E3rabSpacing.medium,
                mainAxisExtent: 245,
              ),
              itemCount: state.lessons.length,
              itemBuilder: (context, index) {
                final lesson = state.lessons[index];
                return LessonCard(
                  lesson: lesson,
                  progress: state.progressFor(lesson.id),
                  bookmarked: state.isBookmarked(lesson.id),
                  onOpen: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BlocProvider.value(
                        value: context.read<LearningCubit>(),
                        child: LessonScreen(lesson: lesson),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
