import 'package:flutter/material.dart';

Future<String?> showParsingReportDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const _ParsingReportDialog(),
  );
}

class _ParsingReportDialog extends StatefulWidget {
  const _ParsingReportDialog();

  @override
  State<_ParsingReportDialog> createState() => _ParsingReportDialogState();
}

class _ParsingReportDialogState extends State<_ParsingReportDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('الإبلاغ عن ملاحظة'),
    content: TextField(
      controller: _controller,
      autofocus: true,
      maxLines: 4,
      maxLength: 500,
      decoration: const InputDecoration(
        hintText: 'اكتب موضع الخطأ أو الملاحظة بوضوح',
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('إلغاء'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _controller.text),
        child: const Text('حفظ البلاغ'),
      ),
    ],
  );
}
