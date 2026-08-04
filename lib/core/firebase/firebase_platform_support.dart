import 'package:flutter/foundation.dart';

abstract final class FirebasePlatformSupport {
  static bool get supportsAccounts {
    if (kIsWeb) return true;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS => true,
      TargetPlatform.windows ||
      TargetPlatform.linux ||
      TargetPlatform.fuchsia => false,
    };
  }

  static bool accountsAvailable({required bool isInitialized}) {
    return isInitialized && supportsAccounts;
  }
}
