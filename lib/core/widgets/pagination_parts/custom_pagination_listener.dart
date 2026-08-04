import 'package:flutter/material.dart';

class CustomPaginationLister extends StatelessWidget {
  final Widget child;
  final VoidCallback onLoading;
  final bool haveNext, isGetPreviousSuccess;

  const CustomPaginationLister({
    super.key,
    required this.child,
    required this.onLoading,
    required this.haveNext,
    required this.isGetPreviousSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification sn) {
        if (haveNext &&
            sn is ScrollUpdateNotification &&
            sn.metrics.pixels >= sn.metrics.maxScrollExtent - 30 &&
            isGetPreviousSuccess) {
          onLoading();
        }
        return true;
      },
      child: child,
    );
  }
}
