import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.title,
    this.onTap,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.minimumHeight = 52,
    this.borderRadius = 8,
  });

  final String title;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double minimumHeight;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final resolvedBackgroundColor = backgroundColor ?? AppColors.primary;
    final resolvedForegroundColor = foregroundColor ?? AppColors.white;

    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, minimumHeight),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: resolvedBackgroundColor,
        foregroundColor: resolvedForegroundColor,
        disabledBackgroundColor: resolvedBackgroundColor.withValues(alpha: 0.6),
        disabledForegroundColor: resolvedForegroundColor,
        elevation: 0,
        tapTargetSize: MaterialTapTargetSize.padded,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: isLoading
            ? SizedBox(
                key: const ValueKey('button-loading'),
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: resolvedForegroundColor,
                ),
              )
            : FittedBox(
                key: const ValueKey('button-title'),
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: true,
                    applyHeightToLastDescent: true,
                  ),
                  style: getBoldStyle(
                    fontSize: 15,
                    fontHeight: 1.4,
                    color: resolvedForegroundColor,
                  ),
                ),
              ),
      ),
    );
  }
}
