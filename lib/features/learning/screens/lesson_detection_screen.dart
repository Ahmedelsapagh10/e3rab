import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../curriculum/data/model/lesson_model.dart';

class LessonDetectionScreen extends StatelessWidget {
  const LessonDetectionScreen({
    super.key,
    required this.lesson,
    required this.onCompleted,
  });

  final LessonModel lesson;
  final Future<void> Function() onCompleted;

  @override
  Widget build(BuildContext context) {
    final sections = lesson.sections.where(
      (item) => const {
        'detection',
        'comparison',
        'misconceptions',
      }.contains(item.type),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('اكتشف')),
      body: ListView(
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
                  Text(
                    'كيف أتعرف إلى ${lesson.shortTitle}؟',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: E3rabSpacing.large),
                  for (final section in sections)
                    Card(
                      margin: const EdgeInsets.only(
                        bottom: E3rabSpacing.medium,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(E3rabSpacing.large),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: E3rabSpacing.small),
                            Text(
                              section.body,
                              style: const TextStyle(height: 1.8),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: E3rabSpacing.small),
                  FilledButton.icon(
                    onPressed: () async {
                      await onCompleted();
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('عرفت كيف أكتشفه'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
