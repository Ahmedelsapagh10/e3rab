import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../cubit/parsing_state.dart';

class ParsingFiltersBar extends StatelessWidget {
  const ParsingFiltersBar({
    super.key,
    required this.state,
    required this.onTrackChanged,
    required this.onDifficultyChanged,
  });

  final ParsingState state;
  final ValueChanged<String?> onTrackChanged;
  final ValueChanged<int?> onDifficultyChanged;

  @override
  Widget build(BuildContext context) {
    final tracks = state.allSamples.map((sample) => sample.trackId).toSet();
    final difficulties =
        state.allSamples.map((sample) => sample.difficulty).toSet().toList()
          ..sort();
    final trackField = DropdownButtonFormField<String?>(
      initialValue: state.selectedTrackId,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'الباب'),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('كل الأبواب', overflow: TextOverflow.ellipsis),
        ),
        ...tracks.map(
          (track) => DropdownMenuItem(
            value: track,
            child: Text(_trackLabel(track), overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: onTrackChanged,
    );
    final difficultyField = DropdownButtonFormField<int?>(
      initialValue: state.selectedDifficulty,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'المستوى'),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('كل المستويات', overflow: TextOverflow.ellipsis),
        ),
        ...difficulties.map(
          (difficulty) => DropdownMenuItem(
            value: difficulty,
            child: Text(
              _difficultyLabel(difficulty),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: onDifficultyChanged,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        E3rabSpacing.medium,
        E3rabSpacing.small,
        E3rabSpacing.medium,
        0,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow =
              constraints.maxWidth < 520 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.3;
          if (narrow) {
            return Column(
              children: [
                trackField,
                const SizedBox(height: E3rabSpacing.small),
                difficultyField,
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: trackField),
              const SizedBox(width: E3rabSpacing.small),
              Expanded(child: difficultyField),
            ],
          );
        },
      ),
    );
  }

  String _trackLabel(String id) => switch (id) {
    'foundations' => 'الأساسيات',
    'signs' => 'علامات الإعراب',
    'nominal' => 'الجملة الاسمية',
    'verbal' => 'الجملة الفعلية',
    'nawasekh' => 'النواسخ',
    'marfouat' => 'المرفوعات',
    'mansoubat' => 'المنصوبات',
    'majrourat' => 'المجرورات',
    'majzoumat' => 'الجزم والشرط',
    'followers' => 'التوابع',
    'working_derivatives' => 'المشتقات العاملة',
    'styles' => 'الأساليب',
    'sentence_positions' => 'محل الجمل',
    'semi_sentences' => 'أشباه الجمل',
    'diptotes' => 'الممنوع من الصرف',
    'numbers' => 'العدد',
    'special_nouns' => 'الأسماء والأدوات الخاصة',
    'applied_parsing' => 'الإعراب التطبيقي',
    _ => id,
  };

  String _difficultyLabel(int value) => switch (value) {
    1 => 'مبتدئ',
    2 => 'متوسط',
    _ => 'متقدم',
  };
}
