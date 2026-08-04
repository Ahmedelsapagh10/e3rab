# Privacy and Data Retention

## Data collected

E3rab minimizes personal data. An authenticated profile may contain email, display name, learning role, curriculum choices, stage, grade, level, goal, locale, and daily target. Learning data includes progress, attempts, mastery, scheduled reviews, bookmarks, and private notes.

The app has no public profiles, chat, advertising SDK, note analytics, or raw-sentence analytics. `learningRole` is a learning preference and never an authorization privilege.

## Guest data

Guest learning data stays in local application storage under a guest-specific key. It remains until the learner resets it, confirms a successful merge into an account, clears application data, or uninstalls the app.

## Account data

Account data is owner-scoped under `e3rab_users/{uid}`. Firestore rules reject unauthenticated and cross-user access. Local account caches use a UID-specific key and are never exposed through the guest owner.

Data is retained while the account exists so offline progress and synchronization can be recovered. Bookmark and note tombstones are retained to prevent deleted items reappearing on another device. The current client does not run a silent time-based purge job.

## User controls

- Reset progress deletes lesson progress, attempts, mastery, and review schedules. Bookmarks and private notes are preserved.
- Account deletion requires email/password reauthentication, deletes every permitted user subcollection and profile document, deletes the Firebase Authentication account, and clears the UID-scoped local cache.
- Firebase security rules permit destructive attempt deletion only for an authenticated owner privacy/reset operation; attempts remain non-updateable during normal learning.

If any remote deletion step fails, the account is not reported as deleted and the user can retry. Never run account-deletion tests against production users.

## Content and administrative data

Curriculum assets contain no student personal data. Draft content in Firestore is readable only by trusted content administrators. Student accounts can read only approved remote packs; guests use bundled local content.

## Operational requirements

- Do not log passwords, tokens, private notes, or user-entered sentences.
- Do not commit service-account keys.
- Replace any Firebase Console test-mode rules before external testing.
- Review this document when analytics, server functions, subscriptions, or a CMS are introduced.
