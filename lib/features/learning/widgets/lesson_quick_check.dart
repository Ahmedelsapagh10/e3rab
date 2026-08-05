import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../curriculum/data/model/exercise_model.dart';

class LessonQuickCheck extends StatefulWidget {
  const LessonQuickCheck({super.key, required this.exercise});

  final ExerciseModel exercise;

  @override
  State<LessonQuickCheck> createState() => _LessonQuickCheckState();
}

class _LessonQuickCheckState extends State<LessonQuickCheck> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final correct =
        _selected != null &&
        widget.exercise.correctAnswerIds.contains(_selected);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.exercise.prompt,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: E3rabSpacing.medium),
        ...widget.exercise.options.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: E3rabSpacing.small),
            child: ChoiceChip(
              selected: _selected == option.id,
              label: SizedBox(width: double.infinity, child: Text(option.text)),
              onSelected: (_) => setState(() => _selected = option.id),
            ),
          ),
        ),
        if (_selected != null)
          Card(
            color: correct
                ? const Color(0xFFE8F5EC)
                : Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(E3rabSpacing.medium),
              child: Text(
                correct
                    ? 'إجابة صحيحة. ${widget.exercise.explanation}'
                    : widget.exercise.explanation,
              ),
            ),
          ),
      ],
    );
  }
}
