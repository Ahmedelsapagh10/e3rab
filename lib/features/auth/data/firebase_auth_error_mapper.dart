import 'package:firebase_auth/firebase_auth.dart';

abstract final class FirebaseAuthErrorMapper {
  static String message(Object error) {
    if (error is! FirebaseAuthException) {
      return 'تعذّر إتمام العملية الآن. حاول مرة أخرى.';
    }

    return switch (error.code) {
      'invalid-email' => 'صيغة البريد الإلكتروني غير صحيحة.',
      'weak-password' => 'اختر كلمة مرور أقوى لا تقل عن 8 أحرف.',
      'email-already-in-use' =>
        'تعذّر إنشاء الحساب بهذه البيانات. جرّب تسجيل الدخول أو الاستعادة.',
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'بيانات تسجيل الدخول غير صحيحة.',
      'user-disabled' => 'هذا الحساب غير متاح حاليًا. تواصل مع الدعم.',
      'too-many-requests' => 'محاولات كثيرة. انتظر قليلًا ثم حاول مجددًا.',
      'network-request-failed' =>
        'تعذّر الاتصال. تحقق من الإنترنت وحاول مرة أخرى.',
      'operation-not-allowed' =>
        'تسجيل الحسابات غير مفعّل حاليًا. يمكنك المتابعة كضيف.',
      _ => 'تعذّر إتمام العملية الآن. حاول مرة أخرى.',
    };
  }
}
