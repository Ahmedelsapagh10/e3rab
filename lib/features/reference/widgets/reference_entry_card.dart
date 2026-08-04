import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../data/model/grammar_reference_entry.dart';

class ReferenceEntryCard extends StatelessWidget {
  const ReferenceEntryCard({
    super.key,
    required this.entry,
    required this.saved,
    required this.onSaved,
    required this.onOpen,
  });

  final GrammarReferenceEntry entry;
  final bool saved;
  final VoidCallback onSaved;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(E3rabSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_icon, semanticLabel: entry.type.label),
                const SizedBox(width: E3rabSpacing.small),
                Expanded(
                  child: Text(
                    entry.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: saved ? 'إزالة من المحفوظ' : 'حفظ في المرجع',
                  onPressed: onSaved,
                  icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
                ),
              ],
            ),
            Wrap(
              spacing: E3rabSpacing.small,
              runSpacing: E3rabSpacing.xSmall,
              children: [
                Chip(label: Text(entry.type.label)),
                if (!entry.isApproved)
                  const Chip(
                    avatar: Icon(Icons.rate_review_outlined, size: 18),
                    label: Text('مسودة قيد المراجعة'),
                  ),
              ],
            ),
            const SizedBox(height: E3rabSpacing.small),
            if (entry.type == GrammarReferenceType.comparison)
              _ComparisonTable(entry: entry)
            else
              Text(entry.body, style: const TextStyle(height: 1.7)),
            const SizedBox(height: E3rabSpacing.small),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.arrow_back),
                label: const Text('افتح الشرح الكامل'),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  IconData get _icon => switch (entry.type) {
    GrammarReferenceType.dictionary => Icons.translate,
    GrammarReferenceType.quickRule => Icons.bolt_outlined,
    GrammarReferenceType.comparison => Icons.compare_arrows,
    GrammarReferenceType.commonMistake => Icons.warning_amber_rounded,
  };
}

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable({required this.entry});

  final GrammarReferenceEntry entry;

  @override
  Widget build(BuildContext context) => Table(
    border: TableBorder.all(color: Theme.of(context).dividerColor),
    columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(3)},
    children: [
      const TableRow(
        children: [
          _TableCell(text: 'الموضوع', heading: true),
          _TableCell(text: 'موضع المقارنة', heading: true),
        ],
      ),
      TableRow(
        children: [
          _TableCell(text: entry.lesson.shortTitle),
          _TableCell(text: entry.body),
        ],
      ),
    ],
  );
}

class _TableCell extends StatelessWidget {
  const _TableCell({required this.text, this.heading = false});

  final String text;
  final bool heading;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(E3rabSpacing.small),
    child: Text(
      text,
      style: heading ? Theme.of(context).textTheme.labelLarge : null,
    ),
  );
}
