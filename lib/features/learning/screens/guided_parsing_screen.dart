import 'package:flutter/material.dart';

import '../../curriculum/data/model/lesson_model.dart';
import '../widgets/guided_parsing_journey.dart';

class GuidedParsingScreen extends StatelessWidget {
  const GuidedParsingScreen({
    super.key,
    required this.lesson,
    required this.onCompleted,
  });

  final LessonModel lesson;
  final Future<void> Function() onCompleted;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('جرّب معي')),
    body: GuidedParsingJourney(
      example: lesson.examples.first,
      onCompleted: () async {
        await onCompleted();
        if (context.mounted) Navigator.pop(context);
      },
    ),
  );
}
