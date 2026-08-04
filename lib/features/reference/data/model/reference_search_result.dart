import 'package:equatable/equatable.dart';

import 'grammar_reference_entry.dart';

class ReferenceSearchResult extends Equatable {
  const ReferenceSearchResult({required this.entry, required this.score});

  final GrammarReferenceEntry entry;
  final int score;

  @override
  List<Object?> get props => [entry, score];
}
