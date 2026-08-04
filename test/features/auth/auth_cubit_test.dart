import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/auth/cubit/auth_cubit.dart';
import 'package:new_strucuture/features/auth/cubit/auth_state.dart';

import 'auth_test_fakes.dart';

void main() {
  test('restoration exposes guest-safe unavailable state', () async {
    final auth = FakeAuthRepository(isAvailable: false);
    final cubit = AuthCubit(auth, FakeUserProfileRepository());

    await cubit.restoreSession();

    expect(cubit.state, isA<AuthUnavailable>());
    await cubit.close();
    await auth.close();
  });

  test('sign in repairs profile and authenticates', () async {
    final auth = FakeAuthRepository();
    final profiles = FakeUserProfileRepository();
    final cubit = AuthCubit(auth, profiles);

    await cubit.signIn(email: 'STUDENT@example.com ', password: '12345678');

    expect(cubit.state, isA<AuthAuthenticated>());
    expect(profiles.repairCalls, 1);
    expect(auth.currentUser?.email, 'student@example.com');
    await cubit.close();
    await auth.close();
  });

  test('duplicate submissions are ignored while a request is active', () async {
    final auth = FakeAuthRepository()..signInGate = Completer<void>();
    final cubit = AuthCubit(auth, FakeUserProfileRepository());

    final first = cubit.signIn(email: 'a@example.com', password: '12345678');
    final second = cubit.signIn(email: 'a@example.com', password: '12345678');
    await second;
    expect(auth.signInCalls, 1);

    auth.signInGate!.complete();
    await first;
    await cubit.close();
    await auth.close();
  });

  test(
    'account creation authenticates and creates a learning profile',
    () async {
      final auth = FakeAuthRepository();
      final profiles = FakeUserProfileRepository();
      final cubit = AuthCubit(auth, profiles);

      await cubit.createAccount(
        email: 'new@example.com',
        password: '12345678',
        displayName: 'متعلم جديد',
      );

      expect(cubit.state, isA<AuthAuthenticated>());
      expect(auth.currentUser?.displayName, 'متعلم جديد');
      expect(profiles.repairCalls, 1);
      await cubit.close();
      await auth.close();
    },
  );

  test('password reset uses a non-enumerating confirmation', () async {
    final auth = FakeAuthRepository();
    final cubit = AuthCubit(auth, FakeUserProfileRepository());

    await cubit.sendPasswordResetEmail('student@example.com');

    expect(cubit.state, isA<AuthPasswordResetSent>());
    await cubit.close();
    await auth.close();
  });

  test('sign out returns to unauthenticated state', () async {
    final auth = FakeAuthRepository(currentUser: testUser);
    final cubit = AuthCubit(auth, FakeUserProfileRepository());

    await cubit.signOut();

    expect(cubit.state, isA<AuthUnauthenticated>());
    expect(auth.currentUser, isNull);
    await cubit.close();
    await auth.close();
  });
}
