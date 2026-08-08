import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../cubit/learning_cubit.dart';
import '../cubit/learning_state.dart';
import '../screens/lesson_screen.dart';
import 'learning_status_view.dart';
import 'lesson_card.dart';

class LearningHubView extends StatelessWidget {
  const LearningHubView({super.key});

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
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'الدروس',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: E3rabSpacing.small),
                    const Text(
                      'اختر الدرس، ثم تنقّل بوضوح بين الشرح والأمثلة والتطبيق.',
                      style: TextStyle(height: 1.7),
                    ),
                    const SizedBox(height: E3rabSpacing.xLarge),
                    ...state.lessons.map(
                      (lesson) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: E3rabSpacing.medium,
                        ),
                        child: LessonCard(
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
}
