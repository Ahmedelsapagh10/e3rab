import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../cubit/learning_cubit.dart';
import '../cubit/learning_state.dart';
import '../screens/lesson_screen.dart';
import 'learning_status_view.dart';
import 'lesson_card.dart';
import 'grammar_coverage_view.dart';
import 'learning_hub_header.dart';

class LearningHubView extends StatelessWidget {
  const LearningHubView({
    super.key,
    required this.onOpenReference,
    required this.onOpenParsingLab,
  });

  final VoidCallback onOpenReference;
  final VoidCallback onOpenParsingLab;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LearningCubit, LearningState>(
      builder: (context, state) => LearningStatusView(
        state: state,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.35;
            final columns = constraints.maxWidth >= 1024
                ? 3
                : constraints.maxWidth >= 680
                ? 2
                : 1;
            final horizontalPadding = constraints.maxWidth > 1028
                ? (constraints.maxWidth - 980) / 2
                : E3rabSpacing.large;
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    E3rabSpacing.large,
                    horizontalPadding,
                    E3rabSpacing.medium,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 980),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LearningHubHeader(
                              onOpenReference: onOpenReference,
                              onOpenParsingLab: onOpenParsingLab,
                            ),
                            const SizedBox(height: E3rabSpacing.xLarge),
                            Text(
                              'الدروس المتاحة',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    E3rabSpacing.small,
                    horizontalPadding,
                    E3rabSpacing.xLarge,
                  ),
                  sliver: SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: largeText ? 1 : columns,
                      crossAxisSpacing: E3rabSpacing.medium,
                      mainAxisSpacing: E3rabSpacing.medium,
                      mainAxisExtent: largeText ? 660 : 300,
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
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    40,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: GrammarCoverageView(tracks: state.coverageTracks),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
