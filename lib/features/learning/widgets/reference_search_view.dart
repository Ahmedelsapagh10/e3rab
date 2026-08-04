import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../reference/cubit/reference_cubit.dart';
import '../../reference/cubit/reference_state.dart';
import '../../reference/data/model/grammar_reference_entry.dart';
import '../cubit/learning_cubit.dart';
import '../screens/lesson_screen.dart';
import '../../reference/widgets/reference_entry_card.dart';
import '../../reference/widgets/reference_filter_bar.dart';
import '../../reference/widgets/reference_status_views.dart';

class ReferenceSearchView extends StatelessWidget {
  const ReferenceSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReferenceCubit, ReferenceState>(
      builder: (context, state) => switch (state.status) {
        ReferenceStatus.initial || ReferenceStatus.loading => const Center(
          child: CircularProgressIndicator(semanticsLabel: 'تحميل المرجع'),
        ),
        ReferenceStatus.failure => ReferenceFailureView(
          message: state.message ?? 'تعذّر فتح المرجع.',
          onRetry: context.read<ReferenceCubit>().load,
        ),
        ReferenceStatus.ready => _ReferenceContent(
          state: state,
          onOpen: (entry) => _open(context, entry),
        ),
      },
    );
  }

  void _open(BuildContext context, GrammarReferenceEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<LearningCubit>(),
          child: LessonScreen(lesson: entry.lesson),
        ),
      ),
    );
  }
}

class _ReferenceContent extends StatelessWidget {
  const _ReferenceContent({required this.state, required this.onOpen});

  final ReferenceState state;
  final ValueChanged<GrammarReferenceEntry> onOpen;

  @override
  Widget build(BuildContext context) {
    final entries = state.visibleEntries;
    return LayoutBuilder(
      builder: (context, constraints) => Center(
        child: SizedBox(
          width: math.min(constraints.maxWidth, 920),
          height: constraints.maxHeight,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  E3rabSpacing.large,
                  E3rabSpacing.large,
                  E3rabSpacing.large,
                  E3rabSpacing.small,
                ),
                child: TextField(
                  textInputAction: TextInputAction.search,
                  onChanged: context.read<ReferenceCubit>().search,
                  decoration: const InputDecoration(
                    labelText: 'ابحث في المصطلحات والقواعد والأمثلة',
                    hintText: 'مثال: المبتدأ، مرفوع، شبه الجملة',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ReferenceFilterBar(state: state),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: E3rabSpacing.large,
                  vertical: E3rabSpacing.small,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('${entries.length} نتيجة'),
                ),
              ),
              Expanded(
                child: entries.isEmpty
                    ? const ReferenceEmptyResults()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          E3rabSpacing.large,
                          0,
                          E3rabSpacing.large,
                          E3rabSpacing.large,
                        ),
                        itemCount: entries.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: E3rabSpacing.small),
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return ReferenceEntryCard(
                            entry: entry,
                            saved: state.isSaved(entry.id),
                            onSaved: () => context
                                .read<ReferenceCubit>()
                                .toggleSaved(entry),
                            onOpen: () => onOpen(entry),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
