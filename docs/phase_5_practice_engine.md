# Phase 5 — Practice Engine

## Delivered

- Reusable practice sessions for lesson, scheduled review, and timed cumulative-test modes.
- Dedicated renderers for choice, classification, and guided-parsing exercises in the current validated content pack.
- Locked scoring weights:
  - First unhinted correct answer: `1.0`.
  - Correct answer after a hint: `0.7`.
  - Correct answer after a prior error: `0.5`.
  - Revealed answer: `0.0`.
- Raw and weighted session results.
- Persistent attempt recording for answers, revealed answers, and timeouts.
- Weak-skill and due-review queue generation based on mastery and review items.
- Cumulative queues interleaved across lessons instead of exhausting one lesson first.
- Five-minute cumulative tests and an equivalent untimed accessibility alternative.
- Explicit countdown semantics, non-color answer indicators, wrapping controls, and large-text coverage.
- Timer disposal when a session finishes or its Cubit closes.

## Architecture

Practice logic remains outside widgets:

```text
ExerciseScreen
  → ExerciseCubit
    → ExerciseAttemptFactory / ExerciseScoringService
    → LessonCompletionService
    → ProgressRepository
      → local storage and optional Firestore data source
```

`PracticeQueueBuilder` creates review and cumulative queues. `LearningCubit` exposes those plans to the review center, while widgets only navigate and render the resulting session.

## Accessibility behavior

- Timed tests never become the only way to access cumulative exercises.
- Remaining time has a screen-reader label and becomes a live region during the last thirty seconds.
- Correct, incorrect, and revealed states use text and icons in addition to color.
- Controls wrap at large text sizes instead of relying on a fixed horizontal row.
- Reveal is unavailable during a timed test, preventing ambiguous zero-score behavior under time pressure.

## Verification coverage

- All four scoring weights.
- Due-skill priority and weak-skill fallback.
- Cross-lesson cumulative queue ordering.
- Hint-weighted lesson completion.
- Zero-weight reveal persistence.
- Timeout persistence and safe completion.
- Classification renderer at large RTL text size.
- Timed countdown visibility and hidden reveal action.

## Deferred by the approved phase plan

- Phase 6 specialist-reviewed parsing laboratory.
- Phase 7 full grammar reference and expanded ranked search.
- Phase 8 teacher mode.
- Phase 9 reviewed curriculum expansion.
- Phase 10 release-quality audit and deployment checklist.
