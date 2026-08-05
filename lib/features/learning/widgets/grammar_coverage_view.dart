import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../curriculum/data/model/grammar_coverage_model.dart';

class GrammarCoverageView extends StatelessWidget {
  const GrammarCoverageView({super.key, required this.tracks});

  final List<GrammarCoverageTrack> tracks;

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) return const SizedBox.shrink();
    final topicCount = tracks.fold<int>(
      0,
      (sum, track) => sum + track.topics.length,
    );
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'خريطة النحو الشاملة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: E3rabSpacing.xSmall),
            Text(
              '${tracks.length} بابًا • $topicCount موضوعًا مرتبة من الأساس إلى الإعراب التطبيقي',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: E3rabBrandColors.muted),
            ),
            const SizedBox(height: E3rabSpacing.medium),
            ...tracks.map(
              (track) => Card(
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: E3rabBrandColors.sky,
                    child: Text('${track.order}'),
                  ),
                  title: Text(
                    track.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text('${track.topics.length} موضوعات'),
                  children: track.topics
                      .map(
                        (topic) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.circle_outlined, size: 16),
                          title: Text(topic),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
