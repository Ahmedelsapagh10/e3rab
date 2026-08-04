import 'package:flutter/material.dart';
import 'package:new_strucuture/core/utils/app_colors.dart';
import 'package:new_strucuture/core/utils/app_constants.dart';
import 'package:new_strucuture/core/utils/app_translation.dart';

class CustomBottomLoading extends StatelessWidget {
  final bool isPaginationLoading, isPaginationFailed;
  final double bottomPadding;

  final VoidCallback onReLoading;

  const CustomBottomLoading({
    super.key,
    required this.isPaginationLoading,
    required this.isPaginationFailed,
    required this.onReLoading,
    this.bottomPadding = 16,
  });

  @override
  Widget build(BuildContext context) {
    return isPaginationLoading
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppConstance().customLoading(),
                const SizedBox(height: AppConstance.vPaddingTiny),
                Text(
                  AppTranslation().loadingMore,
                  style: TextStyle(color: AppColors.grey, fontSize: 12),
                ),
                SizedBox(height: bottomPadding),
              ],
            ),
          )
        : isPaginationFailed
        ? Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    onReLoading();
                  },
                  icon: const Icon(Icons.refresh),
                ),
                Text(
                  AppTranslation().refresh,
                  style: TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();
  }
}
