import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../cubit/parsing_state.dart';

class ParsingStepView extends StatelessWidget {
  const ParsingStepView({
    super.key,
    required this.state,
    required this.onSelect,
    required this.onSubmit,
    required this.onNext,
  });

  final ParsingState state;
  final ValueChanged<String> onSelect;
  final VoidCallback onSubmit;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final sample = state.currentSample;
    final step = state.currentStep;
    return ListView(
      padding: const EdgeInsets.all(E3rabSpacing.large),
      children: [
        LinearProgressIndicator(
          value: (state.stepIndex + 1) / sample.steps.length,
          semanticsLabel: 'تقدم خطوات الإعراب',
        ),
        const SizedBox(height: E3rabSpacing.large),
        Text(
          sample.fullyDiacritizedSentence,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 2),
        ),
        Center(child: Chip(label: Text('موضع التحليل: ${sample.targetText}'))),
        const SizedBox(height: E3rabSpacing.large),
        Text(step.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: E3rabSpacing.small),
        Text(step.prompt, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: E3rabSpacing.medium),
        ...step.options.map(
          (option) => Card(
            child: ListTile(
              enabled: !state.submitted,
              onTap: state.submitted ? null : () => onSelect(option.id),
              leading: Icon(
                state.selectedOptionId == option.id
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: Text(option.text),
              subtitle:
                  state.submitted &&
                      (state.selectedOptionId == option.id ||
                          step.correctOptionId == option.id)
                  ? Text(option.feedback)
                  : null,
              trailing: state.submitted
                  ? Icon(
                      step.correctOptionId == option.id
                          ? Icons.check_circle
                          : state.selectedOptionId == option.id
                          ? Icons.cancel
                          : Icons.circle_outlined,
                      semanticLabel: step.correctOptionId == option.id
                          ? 'الإجابة الصحيحة'
                          : state.selectedOptionId == option.id
                          ? 'اختيار غير صحيح'
                          : null,
                    )
                  : null,
            ),
          ),
        ),
        if (state.submitted)
          Semantics(
            liveRegion: true,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(E3rabSpacing.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.isCorrect ? 'اختيار صحيح' : 'راجع الدليل',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(step.explanation, style: const TextStyle(height: 1.7)),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: E3rabSpacing.medium),
        FilledButton(
          onPressed: state.submitted
              ? onNext
              : state.selectedOptionId == null
              ? null
              : onSubmit,
          child: Text(
            state.submitted
                ? state.isLastStep
                      ? 'قارن بالإعراب المرجعي'
                      : 'الخطوة التالية'
                : 'تحقق',
          ),
        ),
      ],
    );
  }
}
