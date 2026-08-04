enum ContentReviewStatus {
  draft,
  aiAssistedDraft,
  inReview,
  changesRequested,
  approved,
  archived,
}

ContentReviewStatus contentReviewStatusFromJson(String value) {
  return ContentReviewStatus.values.byName(value);
}
