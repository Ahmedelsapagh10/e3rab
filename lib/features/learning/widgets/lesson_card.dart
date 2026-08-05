import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../curriculum/data/model/content_review_status.dart';
import '../../curriculum/data/model/lesson_model.dart';
import '../../progress/data/model/learning_progress_models.dart';
import 'lesson_card_support.dart';

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
    final status = progress?.status ?? LessonProgressStatus.notStarted;
    final completed = status == LessonProgressStatus.completed;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(E3rabSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LessonIcon(completed: completed),
                  const SizedBox(width: E3rabSpacing.medium),
                  Expanded(
                    child: Text(
                      lesson.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (bookmarked)
                    const Icon(Icons.bookmark_rounded, semanticLabel: 'محفوظ'),
                ],
              ),
              const SizedBox(height: E3rabSpacing.medium),
              Text(
                lesson.objectives.first,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
              const SizedBox(height: E3rabSpacing.medium),
              if (_isDocumented(lesson.reviewStatus))
                const LessonDocumentedLabel(),
              const Spacer(),
              Divider(color: Theme.of(context).colorScheme.outlineVariant),
              const SizedBox(height: E3rabSpacing.small),
              LessonCardFooter(
                minutes: lesson.estimatedMinutes,
                exerciseCount: lesson.exerciseIds.length,
                status: status,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isDocumented(ContentReviewStatus status) =>
      status == ContentReviewStatus.sourceDocumented ||
      status == ContentReviewStatus.humanReviewed ||
      status == ContentReviewStatus.approved;
}

class _LessonIcon extends StatelessWidget {
  const _LessonIcon({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: completed ? const Color(0xFFE8F7EE) : E3rabBrandColors.sky,
      borderRadius: BorderRadius.circular(E3rabRadii.medium),
    ),
    child: Icon(
      completed ? Icons.check_rounded : Icons.auto_stories_outlined,
      color: completed
          ? E3rabBrandColors.success
          : E3rabBrandColors.primaryBlue,
    ),
  );
}
