import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../curriculum/data/model/lesson_model.dart';
import 'lesson_phase_tile.dart';

class LessonOverviewView extends StatelessWidget {
  const LessonOverviewView({
    super.key,
    required this.lesson,
    required this.suggestedPhase,
    required this.onPhaseSelected,
  });

  final LessonModel lesson;
  final int suggestedPhase;
  final ValueChanged<int> onPhaseSelected;

  @override
  Widget build(BuildContext context) {
    final phases = [
      (
        Icons.menu_book_outlined,
        '١. افهم',
        'تعرّف إلى المعنى والقاعدة بلغة واضحة.',
      ),
      (
        Icons.search_rounded,
        '٢. اكتشف',
        'تعلّم كيف تتعرّف إلى الوظيفة النحوية.',
      ),
      (
        Icons.visibility_outlined,
        '٣. شاهد الإعراب',
        'شاهد أمثلة محللة كلمةً كلمة.',
      ),
      (
        Icons.assistant_outlined,
        '٤. جرّب معي',
        'ابنِ الإعراب بالترتيب مع توجيه واضح.',
      ),
      (
        Icons.edit_note_rounded,
        '٥. تدرّب وحدك',
        'حل عشرة تدريبات مع شرح بعد كل إجابة.',
      ),
      (
        Icons.fact_check_outlined,
        '٦. اختبر إتقانك',
        'خمسة أسئلة بلا مؤقت؛ النجاح من ٤ إجابات.',
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
                    onTap: () => onPhaseSelected(index),
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
