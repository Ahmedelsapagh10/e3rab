import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_strucuture/core/preferences/flutter_secure_storage.dart';
import 'package:get/get.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light) {
    _initTheme();
  }

  Future<void> _initTheme() async {
    bool isDark = await MySecureStorage.getIsDark();
    emit(isDark ? ThemeMode.dark : ThemeMode.light);

    try {
      Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
    } catch (_) {}
  }

  Future<void> toggleTheme(BuildContext context) async {
    final isDark = state == ThemeMode.dark;
    final newIsDark = !isDark;

    await MySecureStorage.setIsDark(newIsDark);
    emit(newIsDark ? ThemeMode.dark : ThemeMode.light);

    try {
      Get.changeThemeMode(newIsDark ? ThemeMode.dark : ThemeMode.light);
    } catch (_) {}

    log("Theme toggled: isDarkMode=$newIsDark");
  }
}
