import 'package:equatable/equatable.dart';

import '../../progress/data/model/learning_support_models.dart';
import '../data/model/grammar_reference_entry.dart';
import '../data/model/reference_search_result.dart';

enum ReferenceStatus { initial, loading, ready, failure }

class ReferenceState extends Equatable {
  const ReferenceState({
    this.status = ReferenceStatus.initial,
    this.entries = const [],
    this.searchResults = const [],
    this.bookmarks = const [],
    this.query = '',
    this.savedOnly = false,
    this.selectedType,
    this.message,
  });

  final ReferenceStatus status;
  final List<GrammarReferenceEntry> entries;
  final List<ReferenceSearchResult> searchResults;
  final List<BookmarkModel> bookmarks;
  final String query;
  final bool savedOnly;
  final GrammarReferenceType? selectedType;
  final String? message;

  List<GrammarReferenceEntry> get visibleEntries {
    final source = query.isEmpty
        ? entries
        : searchResults.map((result) => result.entry).toList();
    return source
        .where((entry) => selectedType == null || entry.type == selectedType)
        .where((entry) => !savedOnly || isSaved(entry.id))
        .toList(growable: false);
  }

  bool isSaved(String entryId) => bookmarks.any(
    (bookmark) =>
        bookmark.targetType == 'referenceEntry' &&
        bookmark.targetId == entryId &&
        !bookmark.isDeleted,
  );

  ReferenceState copyWith({
    ReferenceStatus? status,
    List<GrammarReferenceEntry>? entries,
    List<ReferenceSearchResult>? searchResults,
    List<BookmarkModel>? bookmarks,
    String? query,
    bool? savedOnly,
    GrammarReferenceType? selectedType,
    bool clearType = false,
    String? message,
  }) {
    return ReferenceState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      searchResults: searchResults ?? this.searchResults,
      bookmarks: bookmarks ?? this.bookmarks,
      query: query ?? this.query,
      savedOnly: savedOnly ?? this.savedOnly,
      selectedType: clearType ? null : selectedType ?? this.selectedType,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    entries,
    searchResults,
    bookmarks,
    query,
    savedOnly,
    selectedType,
    message,
  ];
}
