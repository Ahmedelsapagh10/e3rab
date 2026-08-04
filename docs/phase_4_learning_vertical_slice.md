# Phase 4 — Learning Vertical Slice

## Delivered

- Three independent lessons: أقسام الكلمة، المبتدأ والخبر، والجمل التي لها محل من الإعراب.
- Ten exercises per lesson and thirty exercises in total, with per-option feedback, hints, and explanations.
- Versioned, schema-validated local content loaded behind `CurriculumRepository`.
- Arabic normalized local search without mutating displayed text.
- Guest progress, attempts, mastery, review schedule, bookmarks, and private notes in `SharedPreferences`.
- Account-scoped local caches and Firestore synchronization under `e3rab_users/{uid}` only.
- Explicit guest merge, stable attempt IDs, tombstones, and preserved note conflicts.
- Responsive RTL home, lesson catalog, lesson reader, exercises, review center, and reference search.
- Word-by-word sample parsing showing type, role, state, sign, reason, and explanation.

## Content governance

All sample lessons and exercises remain `aiAssistedDraft`. They are not marked approved and do not name a human reviewer. The Ministry sources establish current official context but do not by themselves constitute specialist grammar approval.

Official sources checked on 2026-08-04:

- Egyptian Ministry e-learning entry for the sixth-primary Arabic student book.
- Egyptian Ministry third-secondary Arabic guidance model for 2025/2026.

Human Arabic grammar specialist review remains required before public curriculum-alignment or authoritative-parsing claims.

## Persistence and synchronization

- Guest namespace: `e3rab_learning_guest_local-guest`.
- Account namespace: `e3rab_learning_account_{uid}`.
- The app restores cloud-owned learning collections before uploading pending local data.
- Duplicate attempt IDs are treated as synchronized.
- Latest progress, mastery, review items, and bookmark tombstones win by timestamp.
- Divergent note bodies are both retained with a conflict identifier.
- Guest data is removed only after a confirmed cloud synchronization.
- Signing out never exposes the account namespace to the next guest.

## Verification

- Content validation verifies three lessons, thirty unique exercises, ten exercises per lesson, option feedback, and draft status.
- Unit tests cover Arabic search, local persistence and isolation, attempt idempotency, scoring weights, mastery, review scheduling, and note conflicts.
- Widget tests cover RTL, large text, adaptive navigation, login, and long Arabic labels.
- Firestore Emulator tests cover profile ownership, all approved subcollections, append-only attempts, unsupported paths, privilege injection, and cross-user denial.

## Remaining release blockers

- Human specialist approval for grammar explanations, exercises, and parsing samples.
- Verification that Email/Password authentication is enabled in the Firebase Console.
- Deployment of the checked-in production Firestore rules before handling real user data.
- Later phases for the reusable practice-engine expansion, parsing laboratory, full reference, teacher mode, curriculum expansion, and release-quality platform verification.
