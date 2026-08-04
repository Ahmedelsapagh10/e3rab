import 'package:flutter/material.dart';

import '../cubit/learning_state.dart';

class LearningStatusView extends StatelessWidget {
  const LearningStatusView({
    super.key,
    required this.state,
    required this.child,
  });

  final LearningState state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      LearningStatus.initial || LearningStatus.loading => Center(
        child: Semantics(
          label: 'جاري تحميل المحتوى المحلي',
          liveRegion: true,
          child: const CircularProgressIndicator(),
        ),
      ),
      LearningStatus.failure => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(state.message ?? 'تعذّر فتح المحتوى المحلي.'),
        ),
      ),
      LearningStatus.ready => child,
    };
  }
}
