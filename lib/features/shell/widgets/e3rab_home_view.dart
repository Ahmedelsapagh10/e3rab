import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../learning/cubit/learning_cubit.dart';
import '../../learning/cubit/learning_state.dart';
import '../../learning/widgets/learning_status_view.dart';
import 'home_hero_card.dart';
import 'home_progress_widgets.dart';
import 'home_reveal.dart';
import 'home_today_plan.dart';

class E3rabHomeView extends StatelessWidget {
  const E3rabHomeView({super.key});

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
                    HomeReveal(child: HomeHeroCard(state: state)),
                    const SizedBox(height: E3rabSpacing.large),
                    HomeReveal(delay: 0.12, child: HomeTodayPlan(state: state)),
                    const SizedBox(height: E3rabSpacing.large),
                    HomeReveal(
                      delay: 0.24,
                      child: HomeProgressSummary(state: state),
                    ),
                    if (state.mastery.isNotEmpty) ...[
                      const SizedBox(height: E3rabSpacing.large),
                      HomeReveal(
                        delay: 0.34,
                        child: HomeWeakSkill(state: state),
                      ),
                    ],
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
