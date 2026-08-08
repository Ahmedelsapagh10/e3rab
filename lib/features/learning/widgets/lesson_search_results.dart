import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../curriculum/data/model/search_result_model.dart';
import '../cubit/learning_cubit.dart';
import '../screens/lesson_screen.dart';

class LessonSearchResults extends StatelessWidget {
  const LessonSearchResults({super.key, required this.results});

  final List<SearchResultModel> results;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'دروس مطابقة',
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: E3rabSpacing.small),
      for (final result in results)
        Card(
          margin: const EdgeInsets.only(bottom: E3rabSpacing.small),
          child: ListTile(
            minTileHeight: E3rabReadingMetrics.minimumTapTarget,
            leading: const Icon(Icons.menu_book_outlined),
            title: Text(result.lesson.title),
            subtitle: Text(result.lesson.objectives.first),
            trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: context.read<LearningCubit>(),
                  child: LessonScreen(lesson: result.lesson),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
