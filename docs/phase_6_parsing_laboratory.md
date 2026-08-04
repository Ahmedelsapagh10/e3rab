# Phase 6 — Parsing Laboratory

## Outcome

The application now contains a guided, local-first parsing laboratory behind a
specialist-review gate. It never accepts unrestricted sentences and never
presents an unreviewed analysis as authoritative.

## Architecture

The feature follows the existing flow:

`ParsingLabView → ParsingCubit → GrammarAnalysisService / ProgressRepository → local assets and owner-scoped storage`

`GrammarAnalysisService` is the stable boundary for a future reviewed remote or
automatic implementation. The current `LocalGrammarAnalysisService` reads the
versioned `e3rab_parsing_bank_v1.json` asset.

## Guided flow

Each sample guides the learner through seven reviewed dimensions:

1. Sentence type.
2. Main structural anchor.
3. Word type.
4. Grammatical role.
5. Grammatical state.
6. Grammatical sign.
7. Reason for the sign.

The result compares the learner's choices with word-by-word parsing, explains
the sign and reason, shows valid alternatives where available, and recommends a
related lesson.

## Review safety

- Normal builds return approved samples only.
- Approved samples require a reviewer identity and a valid review date.
- The three initial samples are `aiAssistedDraft` and therefore hidden from
  learners until a real specialist approves them.
- A developer can inspect drafts only in a debug build with:

  `--dart-define=E3RAB_ENABLE_DRAFT_PARSING=true`

- Preview mode displays a persistent warning that the analysis is unapproved.
- No code path marks content as approved.

## Persistence and privacy

- Saved parsing examples use owner-scoped bookmarks with target type
  `parsingSample`.
- Error reports use private owner-scoped notes with target type `parsingReport`.
- Guest data remains local and offline-capable.
- Authenticated data uses the existing progress repository and synchronizes
  under the user's approved `e3rab_users/{uid}` subcollections.
- Reports are not sent to analytics.

## Current content status

The local bank contains three guided draft samples. The technical feature is
complete, but publishing those samples to learners remains blocked on genuine
Arabic grammar specialist review. Curriculum content continues to load from
local versioned assets; Firebase remains responsible for accounts, user-owned
learning data, and explicitly authorized content seeding.
