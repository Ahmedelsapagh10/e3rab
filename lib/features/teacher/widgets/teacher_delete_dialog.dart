import 'package:flutter/material.dart';

Future<bool> confirmTeacherItemDeletion(
  BuildContext context,
  String itemName,
) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل تريد حذف «$itemName» من مساحة التحضير؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('حذف'),
            ),
          ],
        ),
      ) ??
      false;
}
