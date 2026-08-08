import 'package:flutter/material.dart';

import '../../curriculum/data/model/exercise_model.dart';

class ExerciseOptionTile extends StatelessWidget {
  const ExerciseOptionTile({
    super.key,
    required this.option,
    required this.selected,
    required this.submitted,
    required this.correct,
    required this.revealed,
    required this.showResult,
    required this.onSelected,
  });

  final ExerciseOptionModel option;
  final bool selected;
  final bool submitted;
  final bool correct;
  final bool revealed;
  final bool showResult;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = !submitted || !showResult
        ? selected
              ? scheme.primaryContainer
              : scheme.surface
        : correct
        ? scheme.tertiaryContainer
        : selected
        ? scheme.errorContainer
        : scheme.surface;
    return Card(
      color: color,
      child: ListTile(
        enabled: !submitted,
        onTap: submitted ? null : onSelected,
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          semanticLabel: selected ? 'محدد' : 'غير محدد',
        ),
        title: Text(option.text),
        subtitle: submitted && showResult && (selected || correct || revealed)
            ? Text(option.feedback)
            : null,
        trailing: submitted && showResult
            ? Icon(
                correct
                    ? Icons.check_circle
                    : selected
                    ? Icons.cancel
                    : Icons.circle_outlined,
                semanticLabel: correct
                    ? revealed
                          ? 'هذه هي الإجابة الصحيحة التي تم كشفها'
                          : 'إجابة صحيحة'
                    : selected
                    ? 'إجابة غير صحيحة'
                    : null,
              )
            : null,
      ),
    );
  }
}
