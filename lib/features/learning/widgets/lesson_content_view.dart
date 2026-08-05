import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../curriculum/data/model/content_reference_model.dart';
import '../../curriculum/data/model/exercise_model.dart';
import '../../curriculum/data/model/lesson_model.dart';
import 'lesson_journey_step.dart';

class LessonContentView extends StatefulWidget {
  const LessonContentView({
    super.key,
    required this.lesson,
    required this.references,
    required this.onReference,
    this.quickCheck,
    this.onStartPractice,
    this.initialStepIndex = 0,
    this.onStepCompleted,
  });

  final LessonModel lesson;
  final List<ContentReferenceModel> references;
  final ValueChanged<ContentReferenceModel> onReference;
  final ExerciseModel? quickCheck;
  final VoidCallback? onStartPractice;
  final int initialStepIndex;
  final ValueChanged<String>? onStepCompleted;

  @override
  State<LessonContentView> createState() => _LessonContentViewState();
}

class _LessonContentViewState extends State<LessonContentView> {
  late final PageController _controller;
  late int _index;

  List<LessonJourneyStepData> get _steps => buildLessonJourney(
    lesson: widget.lesson,
    quickCheck: widget.quickCheck,
    references: widget.references,
  );

  @override
  void initState() {
    super.initState();
    _index = widget.initialStepIndex.clamp(0, _steps.length - 1);
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps;
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_index + 1) / steps.length,
          semanticsLabel: 'تقدم الدرس: الخطوة ${_index + 1} من ${steps.length}',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
          child: Row(
            children: [
              Text(
                'الخطوة ${_index + 1} من ${steps.length}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              Text(
                steps[_index].label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (value) => setState(() => _index = value),
            itemCount: steps.length,
            itemBuilder: (context, index) => LessonJourneyStep(
              data: steps[index],
              onReference: widget.onReference,
            ),
          ),
        ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.all(E3rabSpacing.medium),
          child: Row(
            children: [
              if (_index > 0)
                OutlinedButton(
                  onPressed: _previous,
                  child: const Text('السابق'),
                ),
              if (_index > 0) const SizedBox(width: E3rabSpacing.small),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _index == steps.length - 1
                      ? _startPractice
                      : _next,
                  icon: Icon(
                    _index == steps.length - 1
                        ? Icons.task_alt_rounded
                        : Icons.arrow_back_rounded,
                  ),
                  label: Text(
                    _index == steps.length - 1 ? 'ابدأ التدريب' : 'فهمت، تابع',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _next() async {
    widget.onStepCompleted?.call(_steps[_index].id);
    await _controller.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _previous() => _controller.previousPage(
    duration: const Duration(milliseconds: 220),
    curve: Curves.easeOutCubic,
  );

  void _startPractice() {
    widget.onStepCompleted?.call(_steps[_index].id);
    widget.onStartPractice?.call();
  }
}
