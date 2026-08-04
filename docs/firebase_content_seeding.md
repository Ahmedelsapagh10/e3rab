# Firebase Curriculum Content Seeder

The student curriculum remains local-first. This seeder is a controlled migration/development utility that copies schema-validated, catalogued local packs to Firestore for future remote-content work.

The catalog is `assets/content/e3rab_content_catalog_v1.json`. Only entries with `seedEnabled: true` are considered. Each pack is validated independently before any write, so an invalid pack fails the controlled seed run instead of uploading malformed content.

## Firestore structure

```text
e3rab_content_packs/{packId}
├── modules/{moduleId}
├── units/{unitId}
├── lessons/{lessonId}
├── exercises/{exerciseId}
└── references/{referenceId}
```

This structure is separate from student-owned data under `e3rab_users/{uid}`.

## Safety gates

`main.dart` always calls `ContentSeeder.seedIfEnabled()`, but the method writes only when all of these conditions are true:

1. The app is a debug build.
2. `E3RAB_ENABLE_CONTENT_SEED` is explicitly true.
3. Firebase is configured and initialized for the current platform.
4. A Firebase user is already signed in.
5. That user has the trusted custom claim `contentAdmin: true`.
6. Every seed-enabled checked-in content pack passes local schema validation.

The custom claim must be assigned using a trusted Firebase Admin environment. It must never be set from Flutter or stored as an editable profile role.

## Running the seeder

First sign in with the authorized content-admin account and make sure the refreshed ID token contains the trusted claim. Then restart the debug app with:

```bash
flutter run --dart-define=E3RAB_ENABLE_CONTENT_SEED=true
```

The startup log reports only `seeded`, `unchanged`, or `failed`; it never prints tokens, credentials, or content-admin details.

Each pack write is idempotent. If its Firestore document already has the same content checksum, that pack is not rewritten. A failed run can therefore be retried safely.

## Student visibility

- Content admins may read draft packs.
- Signed-in students may read a pack only when its parent `reviewStatus` is `approved`.
- Guests continue to use local assets and have no Firestore access.
- A catalog entry records local publication intent with `learnerEnabled`. The current learner repository still loads only the established vertical slice; multi-pack loading must consult this field when it is introduced after review.
- Current packs are `aiAssistedDraft`, so uploading them does not make them readable or authoritative for students.

The normal startup path never uploads content: without the explicit debug define, `ContentSeeder` exits before reading Firebase or the catalog.

Deploy the checked-in Firestore rules before enabling the seeder against a non-emulator project.
