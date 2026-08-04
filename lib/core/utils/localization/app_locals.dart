import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:new_strucuture/core/preferences/flutter_secure_storage.dart';
import 'package:one_context/one_context.dart';

class AppLocals {
  Future<void> toggleLocal({
    required BuildContext context,
    required Locale locale,
  }) async {
    if (context.locale != locale) {
      await context.setLocale(locale);
      await MySecureStorage.setLanguage(locale.languageCode);
      log('${locale.languageCode} SSSSSS');
      if (!context.mounted) return;
      OneNotification.hardReloadRoot(context);
    }
  }
}
