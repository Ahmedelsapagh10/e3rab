import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';

import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:lottie/lottie.dart';
import 'package:new_strucuture/core/exports.dart';
import 'package:new_strucuture/core/preferences/flutter_secure_storage.dart';
import 'package:new_strucuture/core/utils/extentions.dart';

class AppConstance {
  static const double hPaddingTiny = 8;
  static const double vPaddingTiny = 8;
  static const double hPadding = 16;
  static const double vPadding = 16;
  static const double vPaddingBig = 32;
  static const double gap = 20;
  static const double hPaddingBig = 32;
  static const double radiusBig = 24;
  static const double radiusSmall = 16;
  static const double radiusTiny = 12;

  static const double textFieldH = 18;
  // static const String appVersion = 'v2.5.1.8';
  // static const String copyRights = 'DomApp ©';
  static const String currentVersion = "1.1.28";

  static const String superAdmin = "SA";
  static const String admin = "A";
  static const String viewer = "VI";

  static const String approved = "Approved";
  static const String approvedAr = "مؤكد";
  static const String rejected = "Rejected";
  static const String rejectedAr = "مرفوض";
  static const String pending = "Pending";
  static const String pendingAr = "قيد الانتظار";
  static const String edited = "Edited";
  static const String invitations = "invitation";
  static const String invite = "invite";
  static const String requests = "request";
  static const String history = "history";
  static const String active = "Active";
  static const String activeAr = "Active";
  static const String completed = "Completed";
  static const String completedAr = "مكتمل";
  static const String canceled = "Cancelled";
  static const String canceledAr = "ملغي";
  static const String hold = "Hold";
  static const String holdAr = "معلق";
  static const String holdCapital = "Hold";
  static const String confirmed = "Confirmed";
  static const String confirmedAr = "مؤكد";
  static const String adminRole = "Admin";
  static const String superAdminRole = "Super Admin";
  static const String viewerRole = "Viewer";
  static const String missingData = "missing data";

  static const String mobilePrefixNo = "966";

  static const String supportTicketsToken =
      "EAAUgm6XzF64BO1amwALx6ZCgc3P7rqj5JWh5kqOO7bRQNeOXE4uSHMXwDd5ZCubiXTGMVYXZCzaLJkBzZB1Lq5Skpw2x63W7df998ZAiO1o6VgcHe9znKXuRAMOXvDTsjZAilBIlYtDp1INZButQPifZBSzGJgJH1EdprPzYdyvwvGohNaulKGiJ55D8ZBsOjZARQD";
  //! AMAZON
  static const String accessKey = 'DO801HV9G3RTD2NM9Q6N';
  static const String secretKey = '2cSJwWHR2S9E/8w+Kfa2q5XU9tWL3o+J5KXNVHRpTBQ';
  static const String region = 'blr1';
  static const String bucketName = 'rdapps';
  static const String endpoint = 'https://blr1.digitaloceanspaces.com/';
  static const String destinationPath = 'Uploads/Reports/inspection';
  Future<Map<String, String>> getHeader({bool isToken = true}) async {
    return {
      "Accept": "application/json",
      "Accept-Language": await MySecureStorage.getLanguage(),
      if (isToken)
        "Authorization": "Bearer ${await MySecureStorage.getToken()}",
    };
  }

  Future<String> genralErrorMessage() async {
    return await MySecureStorage.getLanguage() == "ar"
        ? "حدث خطا ما من فضلك حاول مجددا"
        : "an Error occurred please try again";
  }

  Future<String> getCusuomTimeOutMessage() async {
    return await MySecureStorage.getLanguage() == 'ar'
        ? "انتهت المهلة"
        : "Request timed out";
  }

  Future<String> getCusuomConnectionErrorMessage() async {
    return await MySecureStorage.getLanguage() == 'ar'
        ? "مشكلة الاتصال"
        : "Network error";
  }

  void showErrorToast(
    BuildContext context, {
    required String msg,
    int duration = 3,
  }) {
    CherryToast.error(
      textDirection: context.isCurrentLanguageAr()
          ? TextDirection.rtl
          : TextDirection.ltr,
      animationType: AnimationType.fromTop,
      toastDuration: Duration(seconds: duration),
      animationDuration: const Duration(milliseconds: 500),
      title: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.bgDark),
      ),
    ).show(context);
  }

  void showInfoToast(
    BuildContext context, {
    required String msg,
    int duration = 3,
  }) {
    CherryToast.info(
      textDirection: context.isCurrentLanguageAr()
          ? TextDirection.rtl
          : TextDirection.ltr,
      animationType: AnimationType.fromTop,
      toastDuration: Duration(seconds: duration),
      animationDuration: const Duration(milliseconds: 500),
      title: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.bgDark),
      ),
    ).show(context);
  }

  void showSuccesToast(
    BuildContext context, {
    required String msg,
    int duration = 3,
  }) {
    CherryToast.success(
      textDirection: context.isCurrentLanguageAr()
          ? TextDirection.rtl
          : TextDirection.ltr,
      animationType: AnimationType.fromTop,
      toastDuration: Duration(seconds: duration),
      animationDuration: const Duration(milliseconds: 500),
      title: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.bgDark),
      ),
    ).show(context);
  }

  static void showLoading(
    BuildContext context, {
    Widget? progressIndicator,
    String msg = '',
    Function()? cancel,
  }) {
    Loader.show(
      context,
      overlayColor: Colors.black26,
      progressIndicator: SizedBox(
        height: 65,
        width: 65,
        child: LottieBuilder.asset(ImageAssets.loading),
      ),
    );
  }

  Widget customLoading({double? height = 65}) {
    return SizedBox(
      height: height,
      width: height,
      child: LottieBuilder.asset(ImageAssets.loading),
    );
  }
}
