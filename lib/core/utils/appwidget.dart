import 'package:get/get.dart' as gets;
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';

import '../exports.dart';

class AppWidget {
  static void createProgressDialog(BuildContext context, String msg) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          content: Row(
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(width: 16.0),
              Text(
                msg,
                style: TextStyle(color: AppColors.black, fontSize: 15.0),
              ),
            ],
          ),
        );
      },
    );
  }

  //!---------------- Loading Dialog With Logo we will use it  -------------

  OverlayLoaderWithAppIcon loadingDialogWithLogo({
    required bool isLoading,
    required Widget child,
  }) {
    return OverlayLoaderWithAppIcon(
      isLoading: isLoading,
      circularProgressColor: AppColors.primary,
      borderRadius: 15.0,
      appIcon: Image.asset(ImageAssets.appIconWithoutBG),
      child: Container(child: child),
    );
  }

  //!---------------- LoadingDialogWithText  ----------------

  void loadingDialogWithText() {
    gets.Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        insetAnimationCurve: Curves.bounceInOut,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'loading'.tr,
                style: gets.Get.textTheme.labelMedium!.copyWith(
                  color: gets.Get.theme.primaryColor,
                ),
              ),
              const SizedBox(width: 5),
              CircularProgressIndicator(
                color: gets.Get.theme.colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      transitionCurve: Curves.easeInOutBack,
    );
  }

  //!-----------------------------------------------------
}
