# Phase 7 — Reference and Search

## Outcome

The reference destination is now a structured Arabic grammar hub backed by the
versioned local curriculum pack. It provides four distinct views instead of a
flat lesson-only search:

- Grammar dictionary.
- Quick rules.
- Comparison tables.
- Common mistakes.

The current vertical slice produces twelve reference entries: one entry in each
category for each of the three lessons. Reference text is derived from the
canonical lesson sections, so the app does not duplicate or allow conflicting
copies of the same grammar explanation.

## Architecture

The feature follows the existing application flow:

`ReferenceSearchView → ReferenceCubit → GrammarReferenceRepository → CurriculumRepository → local asset data source`

Saved items follow:

`ReferenceCubit → ProgressRepository → local owner storage / authenticated sync`

No widget reads assets, local storage, or Firebase directly.

## Ranked Arabic search

Search keys are created without changing displayed or cited Arabic text. The
normalizer:

- Removes tatweel and Arabic diacritics.
- Folds common Alef, Waw-Hamza, Yeh-Hamza, and Alef-Maqsura variants.
- Normalizes Arabic-Indic and Eastern Arabic-Indic digits.
- Preserves the distinction between `ة` and `ه`.
- Collapses search-key whitespace.

Ranking prioritizes an exact or prefix title match, then title containment,
keywords, and lesson body. Every query token must occur in the indexed entry.
The index covers titles, tags, objectives, examples, diacritized examples,
stages, grades, word types, grammatical roles, states, signs, and sign reasons.

## Saved content and privacy

Reference bookmarks use target type `referenceEntry`. Guest bookmarks stay
offline in guest-owned storage. Authenticated bookmarks use the existing
owner-scoped sync path under `e3rab_users/{uid}/bookmarks` and remain isolated
from other accounts.

## Content status

The reference visibly labels entries whose source lesson is not approved as
`مسودة قيد المراجعة`. The implementation never promotes a lesson or reference
to `approved`; publication quality still requires a real grammar specialist.
Firebase is not required to browse or search the reference, and opening the app
does not upload the local explanations.
