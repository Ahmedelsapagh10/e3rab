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
