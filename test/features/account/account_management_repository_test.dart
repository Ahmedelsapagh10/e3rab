import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/account/data/firebase_account_management_repository.dart';
import 'package:new_strucuture/features/progress/data/data_source/local_learning_data_source.dart';
import 'package:new_strucuture/features/progress/data/local_first_progress_repository.dart';
import 'package:new_strucuture/features/progress/data/model/learning_progress_models.dart';
import 'package:new_strucuture/features/progress/data/model/learning_support_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_test_fakes.dart';

void main() {
  test(
    'deletion reauthenticates, removes profile data, and clears cache',
    () async {
      SharedPreferences.setMockInitialValues({});
      final local = LocalLearningDataSource(
        await SharedPreferences.getInstance(),
      );
      final owner = LearningDataOwner.account(testUser.uid);
      final auth = FakeAuthRepository(currentUser: testUser);
      final profiles = FakeUserProfileRepository();
      final repository = FirebaseAccountManagementRepository(
        auth,
        profiles,
        LocalFirstProgressRepository(local),
        local,
      );
      final now = DateTime.utc(2026, 8, 4);
      await local.saveBookmark(
        owner,
        BookmarkModel(
          id: 'lesson',
          targetType: 'lesson',
          targetId: 'lesson',
          contentVersion: '1.0.0',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final result = await repository.deleteAccount(
        owner: owner,
        password: 'password123',
      );

      expect(result.isRight(), isTrue);
      expect(auth.reauthenticateCalls, 1);
      expect(auth.deleteCalls, 1);
      expect(profiles.deleteCalls, 1);
      expect(local.snapshot(owner).isEmpty, isTrue);
      await local.dispose();
      await auth.close();
    },
  );
}
