import 'dart:developer';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:new_strucuture/core/utils/extentions.dart';
import 'package:new_strucuture/features/splash/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySecureStorage {
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static const String isLogin = "isLogin";
  static const String userRoleID = "userRoleID";
  static const String userID = "userID";
  static const String name = "name";
  static const String image = "image";
  static const String role = "role";
  static const String email = "email";
  static const String mobile = "mobile";
  static const String userGroup = "userGroup";
  static const String roleName = "roleName";
  static const String token = "token";
  static const String nationalId = "nationalId";
  static const String gridView = "gridView";
  static const String language = "language";
  static const String notification = "notification";
  static const String isDark = "isDark";
  static const String showHomeTutorial = "showHomeTutorial";
  static const String showUnactivatedTutorial = "showUnactivatedTutorial";
  static const String deviceToken = "deviceToken";

  // Add more keys for the remaining fields as needed

  static Future<void> clearProfile({required BuildContext context}) async {
    await _secureStorage.delete(key: isLogin);
    await _secureStorage.delete(key: userRoleID);
    await _secureStorage.delete(key: userID);
    await _secureStorage.delete(key: name);
    await _secureStorage.delete(key: image);
    await _secureStorage.delete(key: role);
    await _secureStorage.delete(key: email);
    await _secureStorage.delete(key: mobile);
    await _secureStorage.delete(key: userGroup);
    await _secureStorage.delete(key: roleName);
    await _secureStorage.delete(key: token);
    await _secureStorage.delete(key: gridView);
    await _secureStorage.delete(key: notification);
    await _secureStorage.delete(key: nationalId);
    await _secureStorage.delete(key: isDark);
    // HiveHelper().clearAllData();
    if (!context.mounted) return;
    try {
      context.toAndRemoveAll(const SplashScreen());
    } catch (e) {
      log(e.toString());
    }
  }

  static Future<void> setUserData({
    required String phoneNumber,
    required String name,
    required String userId,
    required String token,
    required bool notification,
    required String nationalId,
    String? imageUrl,
  }) async {
    await setUserID(userId);
    await setName(name);
    await setMobile(phoneNumber);
    await setToken(token);
    await setNationalId(nationalId);
    await setIsLogin(true);
    await setImage(imageUrl ?? '');
    await setNotifiction(notification);
    log('USER DATA SET $imageUrl');
  }

  static Future<void> clearUserData() async {
    await _secureStorage.delete(key: isLogin);
    await _secureStorage.delete(key: userRoleID);
    await _secureStorage.delete(key: userID);
    await _secureStorage.delete(key: name);
    await _secureStorage.delete(key: role);
    await _secureStorage.delete(key: email);
    await _secureStorage.delete(key: mobile);
    await _secureStorage.delete(key: userGroup);
    await _secureStorage.delete(key: roleName);
    await _secureStorage.delete(key: token);
    await _secureStorage.delete(key: notification);
    await _secureStorage.delete(key: nationalId);
    await _secureStorage.delete(key: isDark);
  }

  static Future<String> getUserRoleID() async =>
      await _secureStorage.read(key: userRoleID) ?? "";
  static Future<void> setUserRoleID(String value) async =>
      await _secureStorage.write(key: userRoleID, value: value);

  static Future<String> getUserID() async =>
      await _secureStorage.read(key: userID) ?? "";
  static Future<void> setUserID(String value) async =>
      await _secureStorage.write(key: userID, value: value);

  static Future<String> getName() async =>
      await _secureStorage.read(key: name) ?? "";
  static Future<void> setName(String value) async =>
      await _secureStorage.write(key: name, value: value);

  static Future<String> getRole() async =>
      await _secureStorage.read(key: role) ?? "";
  static Future<void> setRole(String value) async =>
      await _secureStorage.write(key: role, value: value);

  static Future<String> getEmail() async =>
      await _secureStorage.read(key: email) ?? "";
  static Future<void> setEmail(String value) async =>
      await _secureStorage.write(key: email, value: value);

  static Future<String> getMobile({bool? without0}) async {
    if (without0 == true) {
      String? value = await _secureStorage.read(key: mobile);
      if (value != null && value.startsWith("0")) {
        return value.substring(1);
      }
    }
    return await _secureStorage.read(key: mobile) ?? "";
  }

  static Future<void> setMobile(String value) async =>
      await _secureStorage.write(key: mobile, value: value);

  static Future<String> getNationalId() async =>
      await _secureStorage.read(key: nationalId) ?? "";
  static Future<void> setNationalId(String value) async =>
      await _secureStorage.write(key: nationalId, value: value);

  static Future<String> getUserGroup() async =>
      await _secureStorage.read(key: userGroup) ?? "";
  static Future<void> setUserGroup(String value) async =>
      await _secureStorage.write(key: userGroup, value: value);

  static Future<String> getRoleName() async =>
      await _secureStorage.read(key: roleName) ?? "";
  static Future<void> setRoleName(String value) async =>
      await _secureStorage.write(key: roleName, value: value);

  static Future<String> getToken() async =>
      await _secureStorage.read(key: token) ?? "";
  static Future<void> setToken(String value) async =>
      await _secureStorage.write(key: token, value: value);
  static Future<String> getDeviceToken() async =>
      await _secureStorage.read(key: deviceToken) ?? "";
  static Future<void> setDeviceToken(String value) async =>
      await _secureStorage.write(key: deviceToken, value: value);

  static Future<String> getImage() async =>
      await _secureStorage.read(key: image) ?? "";
  static Future<void> setImage(String value) async =>
      await _secureStorage.write(key: image, value: value);

  static Future<String> getLanguage() async =>
      await _secureStorage.read(key: language) ?? "ar";
  static Future<void> setLanguage(String value) async =>
      await _secureStorage.write(key: language, value: value);

  static Future<bool> getIsDark() async {
    String? value = await _secureStorage.read(key: isDark);
    return value == "true";
  }

  static Future<void> setIsDark(bool value) async {
    await _secureStorage.write(key: isDark, value: value.toString());
  }

  static Future<bool> getIsLogin() async {
    String? value = await _secureStorage.read(key: isLogin);
    log('$value IS LOGIN GET');
    await Future.delayed(Duration(seconds: 1));
    return value == "true";
  }

  static Future<void> setIsLogin(bool value) async {
    log('$value IS LOGIN SET');

    await _secureStorage.write(key: isLogin, value: value.toString());
  }

  static Future<bool> getNotification() async {
    String? value = await _secureStorage.read(key: notification);
    return value == "true";
  }

  static Future<void> setNotifiction(bool value) async {
    await _secureStorage.write(key: notification, value: value.toString());
  }

  static Future<bool> getGridView() async {
    String? x = await _secureStorage.read(key: gridView);
    log('$x GRID VIEW GET');
    if (x == null) {
      return true;
    }

    return x == "true";
  }

  static Future<void> setGridView(bool value) async {
    log('$value GRID VIEW SET');

    await _secureStorage.write(key: gridView, value: value.toString());
  }

  static Future<bool> getShowHomeTutorial() async {
    String? value = await _secureStorage.read(key: showHomeTutorial);
    return value == null || value == "true";
  }

  static Future<void> setShowHomeTutorial(bool value) async {
    await _secureStorage.write(key: showHomeTutorial, value: value.toString());
  }

  static Future<bool> getShowUnactivatedTutorial() async {
    String? value = await _secureStorage.read(key: showUnactivatedTutorial);
    return value == null || value == "true";
  }

  static Future<void> setShowUnactivatedTutorial(bool value) async {
    await _secureStorage.write(
      key: showUnactivatedTutorial,
      value: value.toString(),
    );
  }

  Future<void> clearSecureStorageOnReinstall() async {
    String key = 'hasRunBefore';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? hasRunBefore = prefs.getBool(key);
    log("clearSecureStorageOnReinstall check: hasRunBefore=$hasRunBefore");

    if (hasRunBefore == null || !hasRunBefore) {
      log(
        "First run detected or flag missing. Clearing secure storage selectively...",
      );
      // Read all keys
      final allValues = await _secureStorage.readAll();
      log("Keys before selective clear: ${allValues.keys}");

      // Iterate and delete keys except showHomeTutorial
      for (String currentKey in allValues.keys) {
        if (currentKey != MySecureStorage.showHomeTutorial) {
          log("Deleting key: $currentKey");
          await _secureStorage.delete(key: currentKey);
        } else {
          log("Keeping key: $currentKey");
        }
      }

      final valuesAfter = await _secureStorage.readAll();
      log("Keys after selective clear: ${valuesAfter.keys}");

      await prefs.setBool(key, true);
      log("Set hasRunBefore flag to true.");
    }
  }
}
