import 'package:flutter/material.dart';

Future<String?> showLessonNoteDialog(
  BuildContext context, {
  required String initialText,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _LessonNoteDialog(initialText: initialText),
  );
}

class _LessonNoteDialog extends StatefulWidget {
  const _LessonNoteDialog({required this.initialText});

  final String initialText;

  @override
  State<_LessonNoteDialog> createState() => _LessonNoteDialogState();
}

class _LessonNoteDialogState extends State<_LessonNoteDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('ملاحظتي الخاصة'),
    content: TextField(
      controller: _controller,
      minLines: 4,
      maxLines: 8,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'اكتب ملاحظة تساعدك على التذكّر…',
        border: OutlineInputBorder(),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('إلغاء'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _controller.text),
        child: const Text('حفظ'),
      ),
    ],
  );
}
