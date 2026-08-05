import 'package:flutter/foundation.dart';

abstract final class FirebasePlatformSupport {
  static bool get usesDesktopRest {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  static bool get supportsSocialAuth => !usesDesktopRest;

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
