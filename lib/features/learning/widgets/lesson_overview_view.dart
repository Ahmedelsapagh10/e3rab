import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../curriculum/data/model/lesson_model.dart';
import 'lesson_phase_tile.dart';

class LessonOverviewView extends StatelessWidget {
  const LessonOverviewView({
    super.key,
    required this.lesson,
    required this.suggestedPhase,
    required this.onExplanation,
    required this.onExamples,
    required this.onExercises,
    required this.onExam,
  });

  final LessonModel lesson;
  final int suggestedPhase;
  final VoidCallback onExplanation;
  final VoidCallback onExamples;
  final VoidCallback onExercises;
  final VoidCallback onExam;

  @override
  Widget build(BuildContext context) {
    final phases = [
      (
        Icons.menu_book_outlined,
        'الشرح',
        'افهم القاعدة بكلمات واضحة.',
        onExplanation,
      ),
      (
        Icons.lightbulb_outline_rounded,
        'الأمثلة',
        'شاهد ثلاثة أمثلة مشروحة خطوة بخطوة.',
        onExamples,
      ),
      (
        Icons.edit_note_rounded,
        'تدريبات موجّهة',
        'طبّق بهدوء مع تلميحات وشرح فوري.',
        onExercises,
      ),
      (
        Icons.fact_check_outlined,
        'اختبار الدرس',
        'خمسة أسئلة بلا مؤقت، والنتيجة في النهاية.',
        onExam,
      ),
    ];
    return ListView(
      padding: const EdgeInsets.all(E3rabSpacing.large),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  lesson.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: E3rabSpacing.small),
                Text(
                  lesson.objectives.first,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.7),
                ),
                const SizedBox(height: E3rabSpacing.xLarge),
                for (var index = 0; index < phases.length; index++) ...[
                  LessonPhaseTile(
                    icon: phases[index].$1,
                    title: phases[index].$2,
                    subtitle: phases[index].$3,
                    onTap: phases[index].$4,
                    recommended: index == suggestedPhase,
                  ),
                  if (index < phases.length - 1)
                    const SizedBox(height: E3rabSpacing.medium),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
