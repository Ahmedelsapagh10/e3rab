import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../reference/cubit/reference_cubit.dart';
import '../../reference/cubit/reference_state.dart';
import '../data/model/grammar_reference_entry.dart';

class ReferenceFilterBar extends StatelessWidget {
  const ReferenceFilterBar({super.key, required this.state});

  final ReferenceState state;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        ChoiceChip(
          label: const Text('الكل'),
          selected: state.selectedType == null && !state.savedOnly,
          onSelected: (_) {
            context.read<ReferenceCubit>().selectType(null);
            if (state.savedOnly) {
              context.read<ReferenceCubit>().toggleSavedOnly();
            }
          },
        ),
        const SizedBox(width: 8),
        ...GrammarReferenceType.values.map(
          (type) => Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: FilterChip(
              label: Text(type.label),
              selected: state.selectedType == type,
              onSelected: (_) =>
                  context.read<ReferenceCubit>().selectType(type),
            ),
          ),
        ),
        FilterChip(
          avatar: const Icon(Icons.bookmark_outline, size: 18),
          label: const Text('المحفوظ'),
          selected: state.savedOnly,
          onSelected: (_) => context.read<ReferenceCubit>().toggleSavedOnly(),
        ),
      ],
    ),
  );
}
