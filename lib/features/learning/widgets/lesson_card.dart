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
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.all(E3rabSpacing.medium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: E3rabBrandColors.sky,
                borderRadius: BorderRadius.circular(E3rabRadii.medium),
              ),
              child: const Icon(
                Icons.auto_stories_outlined,
                color: E3rabBrandColors.primaryBlue,
              ),
            ),
            const SizedBox(width: E3rabSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lesson.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (bookmarked)
                        const Icon(
                          Icons.bookmark_rounded,
                          semanticLabel: 'محفوظ',
                        ),
                    ],
                  ),
                  const SizedBox(height: E3rabSpacing.small),
                  Text(
                    lesson.objectives.first,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(height: 1.55),
                  ),
                  const SizedBox(height: E3rabSpacing.small),
                  Text(
                    '${lesson.estimatedMinutes} دقيقة',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: E3rabSpacing.medium),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          ],
        ),
      ),
    ),
  );
}
