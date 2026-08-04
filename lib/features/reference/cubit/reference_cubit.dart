import 'package:flutter_bloc/flutter_bloc.dart';

import '../../progress/data/model/learning_progress_models.dart';
import '../../progress/data/model/learning_support_models.dart';
import '../../progress/data/progress_repository.dart';
import '../data/grammar_reference_repository.dart';
import '../data/model/grammar_reference_entry.dart';
import 'reference_state.dart';

class ReferenceCubit extends Cubit<ReferenceState> {
  ReferenceCubit(this._reference, this._progress, this.owner)
    : super(const ReferenceState());

  final GrammarReferenceRepository _reference;
  final ProgressRepository _progress;
  final LearningDataOwner owner;
  int _searchRequest = 0;

  Future<void> load() async {
    emit(state.copyWith(status: ReferenceStatus.loading));
    final result = await _reference.getEntries();
    if (result.isLeft()) {
      emit(
        state.copyWith(
          status: ReferenceStatus.failure,
          message: 'تعذّر فتح المرجع النحوي المحلي.',
        ),
      );
      return;
    }
    final bookmarks = (await _progress.getBookmarks(
      owner,
    )).getOrElse(() => const []);
    emit(
      ReferenceState(
        status: ReferenceStatus.ready,
        entries: result.getOrElse(() => const []),
        bookmarks: bookmarks,
      ),
    );
  }

  Future<void> search(String query) async {
    final normalizedQuery = query.trim();
    final request = ++_searchRequest;
    if (normalizedQuery.isEmpty) {
      emit(state.copyWith(query: '', searchResults: const []));
      return;
    }
    final results = (await _reference.search(
      normalizedQuery,
    )).getOrElse(() => const []);
    if (request == _searchRequest) {
      emit(state.copyWith(query: normalizedQuery, searchResults: results));
    }
  }

  void selectType(GrammarReferenceType? type) {
    emit(state.copyWith(selectedType: type, clearType: type == null));
  }

  void toggleSavedOnly() {
    emit(state.copyWith(savedOnly: !state.savedOnly));
  }

  Future<void> toggleSaved(GrammarReferenceEntry entry) async {
    final existing = state.bookmarks
        .where(
          (bookmark) =>
              bookmark.targetType == 'referenceEntry' &&
              bookmark.targetId == entry.id,
        )
        .firstOrNull;
    final now = DateTime.now().toUtc();
    final bookmark = BookmarkModel(
      id: existing?.id ?? 'reference-${entry.id}',
      targetType: 'referenceEntry',
      targetId: entry.id,
      contentVersion: entry.contentVersion,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      deletedAt: existing == null || existing.isDeleted ? null : now,
    );
    final result = await _progress.saveBookmark(owner, bookmark);
    if (result.isLeft()) return;
    final bookmarks =
        state.bookmarks.where((item) => item.id != bookmark.id).toList()
          ..add(bookmark);
    emit(state.copyWith(bookmarks: bookmarks));
  }
}
