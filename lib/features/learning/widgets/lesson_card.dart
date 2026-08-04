import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../curriculum/data/model/lesson_model.dart';
import '../../progress/data/model/learning_progress_models.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.lesson,
    required this.onOpen,
    this.progress,
    this.bookmarked = false,
  });

  final LessonModel lesson;
  final LessonProgressModel? progress;
  final bool bookmarked;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final completed = progress?.status == LessonProgressStatus.completed;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(E3rabSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    completed
                        ? Icons.check_circle
                        : Icons.auto_stories_outlined,
                    color: completed
                        ? Colors.green
                        : E3rabBrandColors.primaryOrange,
                  ),
                  const SizedBox(width: E3rabSpacing.small),
                  Expanded(
                    child: Text(
                      lesson.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (bookmarked)
                    const Icon(Icons.bookmark, semanticLabel: 'محفوظ'),
                ],
              ),
              const SizedBox(height: E3rabSpacing.medium),
              Text(
                lesson.objectives.first,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
              const Spacer(),
              Wrap(
                spacing: E3rabSpacing.small,
                runSpacing: E3rabSpacing.small,
                children: [
                  Chip(label: Text('${lesson.estimatedMinutes} دقيقة')),
                  Chip(label: Text('${lesson.exerciseIds.length} تمارين')),
                  Chip(label: Text(completed ? 'مكتمل' : 'ابدأ الآن')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
