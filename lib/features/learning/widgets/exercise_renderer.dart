import 'package:flutter/material.dart';

import '../../curriculum/data/model/exercise_model.dart';
import '../cubit/exercise_state.dart';
import 'exercise_option_tile.dart';

class ExerciseRenderer extends StatelessWidget {
  const ExerciseRenderer({
    super.key,
    required this.state,
    required this.onSelect,
  });

  final ExerciseState state;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return switch (state.current.type) {
      ExerciseType.classification => _OptionsRenderer(
        state: state,
        onSelect: onSelect,
        instruction: 'اختر التصنيف الأدق، ثم تحقق من الدليل.',
        icon: Icons.category_outlined,
      ),
      ExerciseType.guidedParsing => _OptionsRenderer(
        state: state,
        onSelect: onSelect,
        instruction: 'خطوة إعرابية موجّهة: حدّد الموقع أو العلامة مع السبب.',
        icon: Icons.account_tree_outlined,
      ),
      _ => _OptionsRenderer(
        state: state,
        onSelect: onSelect,
        instruction: 'اختر إجابة واحدة.',
        icon: Icons.radio_button_checked,
      ),
    };
  }
}

class _OptionsRenderer extends StatelessWidget {
  const _OptionsRenderer({
    required this.state,
    required this.onSelect,
    required this.instruction,
    required this.icon,
  });

  final ExerciseState state;
  final ValueChanged<String> onSelect;
  final String instruction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final exercise = state.current;
    return Semantics(
      container: true,
      label: instruction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon),
            title: Text(instruction),
          ),
          ...exercise.options.map(
            (option) => ExerciseOptionTile(
              option: option,
              selected: state.selectedOptionId == option.id,
              submitted: state.submitted,
              correct: exercise.correctAnswerIds.contains(option.id),
              revealed: state.revealed,
              onSelected: () => onSelect(option.id),
            ),
          ),
        ],
      ),
    );
  }
}
