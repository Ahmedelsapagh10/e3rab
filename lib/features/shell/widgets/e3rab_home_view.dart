import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../learning/cubit/learning_cubit.dart';
import '../../learning/cubit/learning_state.dart';
import '../../learning/widgets/learning_status_view.dart';
import 'home_hero_card.dart';
import 'home_learning_guide.dart';
import 'home_quick_actions.dart';

class E3rabHomeView extends StatelessWidget {
  const E3rabHomeView({
    super.key,
    required this.onOpenLessons,
    required this.onOpenReference,
    required this.onOpenParsingLab,
  });

  final VoidCallback onOpenLessons;
  final VoidCallback onOpenReference;
  final VoidCallback onOpenParsingLab;

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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HomeHeroCard(state: state),
                    const SizedBox(height: E3rabSpacing.large),
                    const HomeLearningGuide(),
                    const SizedBox(height: E3rabSpacing.large),
                    HomeQuickActions(
                      onOpenLessons: onOpenLessons,
                      onOpenReference: onOpenReference,
                      onOpenParsingLab: onOpenParsingLab,
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
