# E3rab Phase 3: Authentication and Shell

Phase 3 replaces the simulated X Store login and visible product flow with the
E3rab account gateway, learner onboarding, and adaptive Arabic shell.

## Runtime flow

```text
AuthGate
├── Firebase unavailable/unconfigured -> account notice + guest entry
├── Signed out -> email login / account creation / password reset / guest
├── Signed in, profile incomplete -> learner profile onboarding
└── Guest or completed profile -> adaptive E3rab shell
```

Firebase is accessed only through:

```text
Screen -> AuthCubit/ProfileCubit -> Repository -> Firebase Data Source
```

SDK classes do not reach Cubit states or screens.

## Authentication

Implemented account operations:

- Email/password account creation and sign-in.
- Restored Firebase sessions through `authStateChanges`.
- Sign-out.
- Password-reset email with a non-enumerating confirmation message.
- Arabic Firebase error mapping.
- Eight-character application password minimum.
- Duplicate-submission prevention.
- Actionable unavailable state with complete guest entry.

Email/Password must be enabled in Firebase Console before external testing.

## Firestore profile

The only root user collection is `e3rab_users`. Profile document IDs and their
`uid` values both equal the authenticated Firebase UID.

Profile creation/repair is transactional and idempotent. It preserves valid
learning preferences, repairs missing required defaults, removes unsupported
legacy fields, and uses server timestamps. Passwords and tokens are never
written to Firestore.

Learner onboarding captures role, country/curriculum, stage, grade, level,
goal, and daily target. Placement testing remains optional and is deferred
until learning content exists.

## Platform behavior

Account UI is enabled on configured Android, iOS, macOS, and Web builds.
Windows and Linux continue in guest mode because production account support is
not declared for those platforms in this release.

Minimum targets now match the current FlutterFire requirements used here:

- Android uses Flutter's current default API 24 (above Firebase's API 23 minimum).
- iOS 15.0.
- macOS 10.15.

If Firebase initialization or notifications fail, application startup
continues and guest mode remains available.

## Phase boundary

Phase 3 does not add curriculum lessons, exercise persistence, guest-progress
merge UI, or cloud learning-data synchronization. Those require the local
learning store and vertical slice introduced in Phase 4.
