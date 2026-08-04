import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/auth/data/firebase_auth_error_mapper.dart';

void main() {
  test('maps invalid credentials without exposing account existence', () {
    final message = FirebaseAuthErrorMapper.message(
      FirebaseAuthException(code: 'user-not-found'),
    );

    expect(message, 'بيانات تسجيل الدخول غير صحيحة.');
  });

  test('maps network errors to actionable Arabic feedback', () {
    final message = FirebaseAuthErrorMapper.message(
      FirebaseAuthException(code: 'network-request-failed'),
    );

    expect(message, contains('تحقق من الإنترنت'));
  });
}
