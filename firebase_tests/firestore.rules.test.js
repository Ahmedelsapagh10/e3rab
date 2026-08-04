const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const { after, before, beforeEach, test } = require('node:test');
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const {
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
} = require('firebase/firestore');

const projectId = 'demo-e3rab';
let environment;

before(async () => {
  environment = await initializeTestEnvironment({
    projectId,
    firestore: {
      host: '127.0.0.1',
      port: 8080,
      rules: readFileSync(join(__dirname, '..', 'firestore.rules'), 'utf8'),
    },
  });
});

beforeEach(async () => environment.clearFirestore());
after(async () => environment.cleanup());

test('owner can create and read an e3rab_users profile', async () => {
  const uid = 'owner';
  const firestore = environment.authenticatedContext(uid).firestore();
  const reference = doc(firestore, 'e3rab_users', uid);

  await assertSucceeds(setDoc(reference, validProfile(uid)));
  await assertSucceeds(getDoc(reference));
  await assertSucceeds(
    updateDoc(reference, {
      learningGoal: 'schoolSuccess',
      updatedAt: serverTimestamp(),
    }),
  );
});

test('other accounts and unauthenticated clients cannot read a profile', async () => {
  await seedProfile('owner');
  const other = environment.authenticatedContext('other').firestore();
  const guest = environment.unauthenticatedContext().firestore();

  await assertFails(getDoc(doc(other, 'e3rab_users', 'owner')));
  await assertFails(getDoc(doc(guest, 'e3rab_users', 'owner')));
});

test('profile creation rejects UID mismatch and privilege injection', async () => {
  const firestore = environment.authenticatedContext('owner').firestore();
  const reference = doc(firestore, 'e3rab_users', 'owner');

  await assertFails(setDoc(reference, validProfile('another-user')));
  await assertFails(
    setDoc(reference, {...validProfile('owner'), authorizationRole: 'admin'}),
  );
});

test('owner can repair a legacy profile missing timestamps', async () => {
  await environment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'e3rab_users', 'owner'), {
      uid: 'owner',
    });
  });
  const firestore = environment.authenticatedContext('owner').firestore();

  await assertSucceeds(
    setDoc(doc(firestore, 'e3rab_users', 'owner'), validProfile('owner')),
  );
});

test('owner can write progress but unsupported subcollections are denied', async () => {
  await seedProfile('owner');
  const firestore = environment.authenticatedContext('owner').firestore();
  const progress = doc(
    firestore,
    'e3rab_users/owner/lesson_progress/lesson-1',
  );
  const unsupported = doc(
    firestore,
    'e3rab_users/owner/private_admin/document-1',
  );

  await assertSucceeds(setDoc(progress, validProgress('lesson-1')));
  await assertFails(setDoc(unsupported, {enabled: true}));
});

test('exercise attempts are append-only', async () => {
  await seedProfile('owner');
  const firestore = environment.authenticatedContext('owner').firestore();
  const reference = doc(
    firestore,
    'e3rab_users/owner/exercise_attempts/attempt-1',
  );

  await assertSucceeds(setDoc(reference, validAttempt('attempt-1')));
  await assertFails(updateDoc(reference, {isCorrect: false}));
});

test('owner can access every permitted learning subcollection', async () => {
  await seedProfile('owner');
  const firestore = environment.authenticatedContext('owner').firestore();
  const base = 'e3rab_users/owner';

  await assertSucceeds(setDoc(doc(firestore, `${base}/skill_mastery/skill-1`), validMastery()));
  await assertSucceeds(setDoc(doc(firestore, `${base}/review_items/skill-skill-1`), validReview()));
  await assertSucceeds(setDoc(doc(firestore, `${base}/bookmarks/lesson-1`), validBookmark()));
  await assertSucceeds(setDoc(doc(firestore, `${base}/notes/lesson-1`), validNote()));
});

test('another account cannot access owner learning data', async () => {
  await seedProfile('owner');
  const owner = environment.authenticatedContext('owner').firestore();
  const other = environment.authenticatedContext('other').firestore();
  const path = 'e3rab_users/owner/bookmarks/lesson-1';
  await setDoc(doc(owner, path), validBookmark());

  await assertFails(getDoc(doc(other, path)));
  await assertFails(setDoc(doc(other, path), validBookmark()));
});

test('teacher workspace notes remain private to their owner', async () => {
  await seedProfile('owner');
  const owner = environment.authenticatedContext('owner').firestore();
  const other = environment.authenticatedContext('other').firestore();
  const path = 'e3rab_users/owner/notes/collection-1';
  const teacherNote = {
    noteId: 'collection-1',
    targetType: 'teacherCollection',
    targetId: 'collection-1',
    text: '{"id":"collection-1","title":"فصل أ"}',
    localVersion: 1,
    deletedAt: null,
    schemaVersion: 1,
    updatedAt: serverTimestamp(),
  };

  await assertSucceeds(setDoc(doc(owner, path), teacherNote));
  await assertFails(getDoc(doc(other, path)));
  await assertFails(setDoc(doc(other, path), teacherNote));
});

test('content admin can seed only the explicit content collections', async () => {
  const admin = environment.authenticatedContext('admin', {
    contentAdmin: true,
  }).firestore();
  const pack = doc(admin, 'e3rab_content_packs/pack-1');

  await assertSucceeds(setDoc(pack, validContentPack('admin')));
  await assertSucceeds(setDoc(
    doc(admin, 'e3rab_content_packs/pack-1/lessons/lesson-1'),
    {id: 'lesson-1', title: 'درس'},
  ));
  await assertFails(setDoc(
    doc(admin, 'e3rab_content_packs/pack-1/admin_data/item-1'),
    {id: 'item-1'},
  ));
});

test('ordinary accounts cannot seed or read draft content', async () => {
  const admin = environment.authenticatedContext('admin', {
    contentAdmin: true,
  }).firestore();
  const student = environment.authenticatedContext('student').firestore();
  const packPath = 'e3rab_content_packs/pack-1';
  await setDoc(doc(admin, packPath), validContentPack('admin'));

  await assertFails(getDoc(doc(student, packPath)));
  await assertFails(setDoc(doc(student, packPath), validContentPack('student')));
});

test('signed-in students can read approved seeded content but guests cannot', async () => {
  const admin = environment.authenticatedContext('admin', {
    contentAdmin: true,
  }).firestore();
  const student = environment.authenticatedContext('student').firestore();
  const guest = environment.unauthenticatedContext().firestore();
  const packPath = 'e3rab_content_packs/pack-1';
  const lessonPath = `${packPath}/lessons/lesson-1`;
  await setDoc(doc(admin, packPath), validContentPack('admin', 'approved'));
  await setDoc(doc(admin, lessonPath), {id: 'lesson-1', title: 'درس'});

  await assertSucceeds(getDoc(doc(student, packPath)));
  await assertSucceeds(getDoc(doc(student, lessonPath)));
  await assertFails(getDoc(doc(guest, lessonPath)));
});

async function seedProfile(uid) {
  await environment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'e3rab_users', uid), {
      ...validProfile(uid),
      createdAt: new Date(),
      updatedAt: new Date(),
    });
  });
}

function validProfile(uid) {
  return {
    uid,
    email: `${uid}@example.com`,
    authProviders: ['password'],
    learningRole: 'student',
    countryCode: 'EG',
    preferredLocale: 'ar',
    onboardingCompleted: false,
    profileSchemaVersion: 1,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  };
}

function validProgress(lessonId) {
  return {
    lessonId,
    contentVersion: '1.0.0',
    status: 'inProgress',
    completedSectionIds: [],
    attemptCount: 0,
    bestScore: 0,
    masteryScore: 0,
    updatedAt: serverTimestamp(),
    schemaVersion: 1,
  };
}

function validAttempt(attemptId) {
  return {
    attemptId,
    exerciseId: 'exercise-1',
    lessonId: 'lesson-1',
    skillIds: ['parts-of-speech'],
    contentVersion: '1.0.0',
    selectedAnswer: 'option-1',
    isCorrect: true,
    scoreWeight: 1,
    hintUsed: false,
    attemptNumber: 1,
    durationMilliseconds: 1200,
    clientCreatedAt: new Date(),
    serverCreatedAt: serverTimestamp(),
    schemaVersion: 1,
  };
}

function validMastery() {
  return {
    skillId: 'skill-1', score: 0.8, state: 'needsReview',
    scoredAttemptCount: 4, unhintedCorrectCount: 2,
    lastPracticedAt: new Date(), nextReviewAt: new Date(),
    algorithmVersion: 1, updatedAt: serverTimestamp(),
  };
}

function validReview() {
  return {
    targetType: 'skill', targetId: 'skill-1', dueAt: new Date(),
    intervalLevel: 0, lastResult: 'correct', algorithmVersion: 1,
    updatedAt: serverTimestamp(),
  };
}

function validBookmark() {
  return {
    bookmarkId: 'lesson-1', targetType: 'lesson', targetId: 'lesson-1',
    contentVersion: '1.0.0', createdAt: new Date(), deletedAt: null,
    updatedAt: serverTimestamp(),
  };
}

function validNote() {
  return {
    noteId: 'lesson-1', targetType: 'lesson', targetId: 'lesson-1',
    text: 'private note', localVersion: 1, deletedAt: null,
    schemaVersion: 1, updatedAt: serverTimestamp(),
  };
}

function validContentPack(uid, reviewStatus = 'aiAssistedDraft') {
  return {
    packId: 'pack-1',
    schemaVersion: 1,
    contentVersion: '1.0.0',
    curriculumVersion: 'egypt-draft-v1',
    locale: 'ar',
    entityIds: ['lesson-1'],
    checksum: 'checksum-1',
    minimumAppVersion: '1.0.0',
    reviewStatus,
    seededBy: uid,
    seededAt: serverTimestamp(),
  };
}
