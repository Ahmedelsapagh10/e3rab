import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../../core/search/arabic_search_normalizer.dart';
import '../../curriculum/data/model/lesson_model.dart';
import '../cubit/learning_cubit.dart';
import '../cubit/learning_state.dart';
import '../screens/lesson_screen.dart';

class CurriculumTrackList extends StatelessWidget {
  const CurriculumTrackList({
    super.key,
    required this.state,
    required this.query,
    this.showEmptyMessage = true,
  });

  final LearningState state;
  final String query;
  final bool showEmptyMessage;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = ArabicSearchNormalizer.normalize(query);
    final tracks = state.coverageTracks.where((track) {
      return normalizedQuery.isEmpty ||
          ArabicSearchNormalizer.normalize(
            track.title,
          ).contains(normalizedQuery) ||
          track.topics.any(
            (topic) => ArabicSearchNormalizer.normalize(
              topic,
            ).contains(normalizedQuery),
          );
    });
    if (tracks.isEmpty) {
      if (!showEmptyMessage) return const SizedBox.shrink();
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: E3rabSpacing.xxLarge),
        child: Center(child: Text('لا توجد نتيجة مطابقة في أبواب النحو.')),
      );
    }
    return Column(
      children: [
        for (final track in tracks)
          Card(
            margin: const EdgeInsets.only(bottom: E3rabSpacing.medium),
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              initiallyExpanded: query.isNotEmpty || track.order == 1,
              leading: CircleAvatar(child: Text('${track.order}')),
              title: Text(
                track.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('${track.topics.length} موضوعات'),
              children: [
                for (final entry in track.topics.indexed)
                  if (normalizedQuery.isEmpty ||
                      ArabicSearchNormalizer.normalize(
                        track.title,
                      ).contains(normalizedQuery) ||
                      ArabicSearchNormalizer.normalize(
                        entry.$2,
                      ).contains(normalizedQuery))
                    _TopicRow(
                      topic: entry.$2,
                      lesson: _lessonFor(
                        track.topicIds[entry.$1],
                        state.lessons,
                      ),
                    ),
              ],
            ),
          ),
      ],
    );
  }

  LessonModel? _lessonFor(String topicId, List<LessonModel> lessons) =>
      lessons.where((lesson) => lesson.topicId == topicId).firstOrNull;
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.topic, required this.lesson});

  final String topic;
  final LessonModel? lesson;

  @override
  Widget build(BuildContext context) => ListTile(
    minTileHeight: E3rabReadingMetrics.minimumTapTarget,
    title: Text(topic),
    subtitle: lesson == null ? const Text('قيد المراجعة النحوية') : null,
    trailing: lesson == null
        ? const Icon(Icons.lock_clock_outlined)
        : const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
    onTap: lesson == null
        ? null
        : () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider.value(
                value: context.read<LearningCubit>(),
                child: LessonScreen(lesson: lesson!),
              ),
            ),
          ),
  );
}
