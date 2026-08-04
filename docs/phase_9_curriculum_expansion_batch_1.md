# Phase 9 — Curriculum Expansion, Batch 1

## Outcome

The first versioned Egyptian-curriculum batch adds one Secondary 2 grammar lesson, ten exercises, a dated curriculum mapping, and a local content-pack catalog.

The batch is deliberately not published to learners. Its content and mapping are `aiAssistedDraft`, have no invented reviewer, and remain behind `learnerEnabled: false` until a qualified Arabic grammar specialist reviews them.

## Verified placement

The checked source is the Ministry of Education's [2025/2026 Secondary 2, term-one, week-six Arabic assessment material](https://elearnningcontent.blob.core.windows.net/elearnningcontent/content/2026/Secondry/Secondry2/Term1/ClassrHomeAssessmentsTest/Arabic_language_Secondary2_TR1_C-W6.pdf). It names the grammar outcome `جزم المضارع في جواب الطلب`. The mapping records the source URL and the check date `2026-08-04`.

The Ministry's [2025/2026 year-plan announcement](https://moe.gov.eg/what-s-on/news/for-pre-1/) establishes the academic-year context and two-term distribution. Current Ministry e-learning landing pages also establish that official Arabic student-book listings exist for the selected stages, but their current download links were not reliably retrievable during this batch. No precise topic mapping was inferred from those landing pages.

This batch therefore makes one narrow, evidence-backed placement claim only. The official material supports the placement and outcome; it does not constitute human approval of E3rab's authored explanation, examples, or distractor feedback.

## Local-first structure

- `e3rab_curriculum_matrix_egypt_2025_2026_v1.json` stores the dated mapping separately from canonical grammar concepts.
- `e3rab_content_catalog_v1.json` registers immutable pack IDs, content and curriculum versions, seed eligibility, and learner publication eligibility.
- `e3rab_egypt_secondary2_term1_batch1_v1.json` contains one lesson and ten exercises with stable IDs and per-option feedback.
- The learner data source reads the catalog and combines only `learnerEnabled` packs after validating each pack and rejecting cross-pack ID collisions. The new batch cannot appear in student search, lessons, progress, or teacher presentation while its publication flag remains false.
- The controlled Firebase seeder reads every `seedEnabled` catalog entry, validates it, hashes it, and performs idempotent writes behind the existing debug, Firebase, signed-in, and trusted-claim gates.

Opening a normal build does not upload curriculum content.

## Storage decision

Versioned JSON assets plus the existing local user-learning store remain proportionate for the current four lessons and forty exercises. No database package was added.

A cross-platform embedded content database should be reconsidered only after measured pack growth makes full JSON decoding, in-memory indexing, or atomic pack installation a real constraint. The evaluation must cover Android, iOS, Web, Windows, macOS, and Linux; transactional pack installation; migrations; integrity hashes; rollback; offline search indexing; and archived-version retention. Drift/SQLite with an explicitly verified web/WASM path is a candidate, not an approved dependency.

## Future CMS contract

A future CMS/API should expose immutable versioned pack manifests containing:

- Pack, schema, content, curriculum, locale, and minimum-app versions.
- Full-pack or delta URLs, byte size, and a cryptographic checksum.
- Review status plus reviewer identity issued by a trusted server, never by the Flutter client.
- Official source metadata and curriculum mapping IDs.
- Created, reviewed, published, superseded, and archived timestamps.
- An explicit rollback target and compatibility policy.
- ETag/`If-None-Match` support and deterministic idempotency keys.

The client must download to a staging area, validate schema and checksum, install atomically, retain the last known-good pack, and never promote draft content based on a client-editable field.

## Publication blockers

- Human specialist review of the lesson, parsed examples, all answers, and all feedback.
- Reviewer identity and review date.
- Explicit transition through the approved content workflow.
- A deliberate catalog publication change after tests pass.
- Continued official-source verification for each additional grade, term, unit, and outcome.

The next curriculum batch must remain separately reviewable and must stop again for approval.
