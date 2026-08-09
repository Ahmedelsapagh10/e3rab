enum ContentReviewStatus {
  draft,
  aiAssistedDraft,
  inReview,
  changesRequested,
  sourceDocumented,
  humanReviewed,
  approved,
  archived,
}

ContentReviewStatus contentReviewStatusFromJson(String value) {
  return ContentReviewStatus.values.byName(value);
}

extension ContentReviewStatusAccess on ContentReviewStatus {
  bool get isLearnerReady => const {
    ContentReviewStatus.sourceDocumented,
    ContentReviewStatus.humanReviewed,
    ContentReviewStatus.approved,
  }.contains(this);
}
