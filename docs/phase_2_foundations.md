# E3rab Phase 2 Foundations

This document describes the contracts introduced before Firebase Auth,
Firestore, or the learning UI are wired into the application.

## Architecture

The project keeps its existing feature-first flow:

```text
Screen -> Cubit -> Repository -> Data Source
```

Phase 2 adds repository contracts and serializable application models only.
Firebase SDK types must be mapped inside Phase 3 data sources and must not reach
Cubits or widgets.

New feature foundations:

- `features/auth`: authentication session contract.
- `features/profile`: the `e3rab_users/{uid}` profile model and repository.
- `features/curriculum`: curriculum, lesson, exercise, and content-pack models.
- `features/progress`: guest/account progress ownership and attempt contracts.
- `features/sync`: guest merge and pending-sync contracts.

## Firestore ownership

Authenticated learning data uses this root only:

```text
e3rab_users/{uid}
├── lesson_progress/{lessonId}
├── exercise_attempts/{attemptId}
├── skill_mastery/{skillId}
├── review_items/{reviewItemId}
├── bookmarks/{bookmarkId}
└── notes/{noteId}
```

The checked-in rules require the authenticated UID to equal the path UID.
Exercise attempts are append-only. Bookmarks and notes use updateable documents
so Phase 3 can implement tombstones and conflict preservation.

The `learningRole` field is a learning preference, not an authorization role.
Client writes cannot add an `authorizationRole` field.

Run rule tests against the local emulator:

```bash
npm --prefix firebase_tests install
firebase emulators:exec --only firestore --project demo-e3rab \
  "npm --prefix firebase_tests test"
```

Never run destructive security tests against production data.

## Content packs

Content is local-first and packaged in versioned JSON. Each pack contains a
manifest plus module, unit, lesson, exercise, and reference lists.

The validator enforces required manifest fields, unique IDs and lesson slugs,
entity relationships, supported review statuses, human review metadata for
approved lessons, answer integrity, per-option feedback, and manifest coverage.
Phase 4 will add parsed-word ranges, prerequisite cycles, assets, and checksums.

## Guest and account separation

`LearningDataOwner` distinguishes guest storage from account storage. Phase 3
implementations must namespace local data by owner and must not expose cached
account notes after sign-out.

Guest-to-account merge must keep local data until cloud confirmation,
deduplicate attempts by stable ID, recompute mastery, respect bookmark
tombstones, and preserve conflicting note versions.

## Design foundation

`E3rabBrandColors` defines the approved orange, yellow, and warm ink colors.
Existing themes are not rewired until the E3rab shell in Phase 3.

`E3rabAdaptiveScaffold` uses bottom navigation below 600 px, a navigation rail
from 600 px, and an extended navigation rail from 1024 px.

## Platform boundaries

Core guest learning targets every Flutter platform. Official FlutterFire Auth
and Firestore do not support Linux, while Windows support is not production
ready. Production cloud accounts are therefore scoped to Android, iOS, macOS,
and Web until official support changes.

Before Phase 3 wiring:

- Raise Android minimum SDK to 23.
- Align all iOS deployment settings to 15.0.
- Raise macOS deployment target to 10.15.
- Confirm Email/Password and Firestore in Firebase Console.
- Replace open Console rules with `firestore.rules`.

## Phase 3 boundary

Phase 2 deliberately does not add Firebase Auth/Firestore packages, replace the
simulated login, write cloud data, replace X Store routes, or add production
grammar lessons.
