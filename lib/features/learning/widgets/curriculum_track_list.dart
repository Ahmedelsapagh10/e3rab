import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../curriculum/data/model/lesson_model.dart';
import '../cubit/learning_cubit.dart';
import '../cubit/learning_state.dart';
import '../screens/lesson_screen.dart';

class CurriculumTrackList extends StatelessWidget {
  const CurriculumTrackList({
    super.key,
    required this.state,
    required this.query,
  });

  final LearningState state;
  final String query;

  @override
  Widget build(BuildContext context) {
    final tracks = state.coverageTracks.where((track) {
      return query.isEmpty ||
          track.title.toLowerCase().contains(query) ||
          track.topics.any((topic) => topic.toLowerCase().contains(query));
    });
    if (tracks.isEmpty) {
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
                for (final topic in track.topics)
                  if (query.isEmpty ||
                      track.title.toLowerCase().contains(query) ||
                      topic.toLowerCase().contains(query))
                    _TopicRow(
                      topic: topic,
                      lesson: _lessonFor(topic, state.lessons),
                    ),
              ],
            ),
          ),
      ],
    );
  }

  LessonModel? _lessonFor(String topic, List<LessonModel> lessons) {
    const aliases = {
      'الاسم والفعل والحرف وعلاماتها': 'أقسام الكلمة',
      'الجمل التي لها محل': 'الجمل التي لها محل من الإعراب',
    };
    final target = aliases[topic] ?? topic;
    return lessons
        .where(
          (lesson) =>
              lesson.title.contains(target) || target.contains(lesson.title),
        )
        .firstOrNull;
  }
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
