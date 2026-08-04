# Phase 8 — Teacher Mode

## Outcome

Teacher Mode is available from the home screen without adding a sixth compact
navigation destination. It supports guest teachers offline and authenticated
teachers with the existing owner-scoped synchronization.

The mode provides:

- Lesson objectives.
- Prerequisites resolved to lesson names.
- Common misconceptions for classroom discussion.
- A large classroom presentation mode.
- Private lesson notes.
- Named lesson collections.
- Named revision sets containing their stable exercise IDs.

## Architecture

The implementation follows the project flow:

`TeacherModeScreen → TeacherCubit → TeacherWorkspaceRepository → ProgressRepository → local / Firestore data sources`

The presentation content follows:

`TeacherPresentationScreen ← TeacherPresentationBuilder ← canonical LessonModel`

Widgets do not read assets, storage, or Firebase directly.

## Persistence and Firestore

The locked Firestore structure remains unchanged. Teacher data uses separate
documents inside the existing private notes subcollection:

- `teacherCollection` for each lesson collection.
- `teacherRevisionSet` for each revision set.
- `teacherPrivateNote` for each private lesson note.

Using one note document per item prevents an indefinitely growing workspace
document. Deleted items use tombstones. Existing note conflict handling keeps
both versions, and Teacher Mode exposes a preserved conflict as a separately
named `نسخة تعارض` item rather than silently dropping it.

Collections are limited to 50 lessons, and revision sets to 20 lessons and 200
exercises. These bounds keep every structured note safely below the Firestore
rule limit while providing actionable Arabic feedback instead of truncating it.

Guest data remains isolated under its guest owner key. Authenticated data syncs
only under `e3rab_users/{uid}/notes`. Notes are not sent to analytics.

## Classroom presentation

Slides are generated locally from canonical lesson metadata, sections, and
reviewed examples. They include objectives, prerequisites, rules, reasoning,
common mistakes, summaries, and word-level parsing where available.

The presentation supports touch controls, PageView gestures, visible position,
screen-reader slide labels, and keyboard navigation with arrow keys or Space.
Unapproved source lessons remain visibly identified as content awaiting
specialist review; the mode never promotes content to `approved`.

## Current scope

Teacher Mode works with the three vertical-slice lessons and their thirty
exercises. It expands automatically as reviewed local content packs are added.
Opening the app does not upload curriculum explanations to Firebase.
