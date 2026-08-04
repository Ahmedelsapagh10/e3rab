import 'package:flutter/material.dart';

import '../../curriculum/data/model/lesson_model.dart';

class TeacherItemDraft {
  const TeacherItemDraft({required this.title, required this.lessonIds});

  final String title;
  final List<String> lessonIds;
}

Future<TeacherItemDraft?> showTeacherItemDialog(
  BuildContext context, {
  required String title,
  required String actionLabel,
  required List<LessonModel> lessons,
}) {
  return showDialog<TeacherItemDraft>(
    context: context,
    builder: (_) => _TeacherItemDialog(
      title: title,
      actionLabel: actionLabel,
      lessons: lessons,
    ),
  );
}

class _TeacherItemDialog extends StatefulWidget {
  const _TeacherItemDialog({
    required this.title,
    required this.actionLabel,
    required this.lessons,
  });

  final String title;
  final String actionLabel;
  final List<LessonModel> lessons;

  @override
  State<_TeacherItemDialog> createState() => _TeacherItemDialogState();
}

class _TeacherItemDialogState extends State<_TeacherItemDialog> {
  final _controller = TextEditingController();
  final _selected = <String>{};

  bool get _canSave =>
      _controller.text.trim().isNotEmpty && _selected.isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(
      width: 520,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              maxLength: 80,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'اسم واضح',
                border: OutlineInputBorder(),
              ),
            ),
            ...widget.lessons.map(
              (lesson) => CheckboxListTile(
                value: _selected.contains(lesson.id),
                title: Text(lesson.title),
                onChanged: (checked) => setState(() {
                  checked == true
                      ? _selected.add(lesson.id)
                      : _selected.remove(lesson.id);
                }),
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('إلغاء'),
      ),
      FilledButton(
        onPressed: _canSave
            ? () => Navigator.pop(
                context,
                TeacherItemDraft(
                  title: _controller.text.trim(),
                  lessonIds: _selected.toList(growable: false),
                ),
              )
            : null,
        child: Text(widget.actionLabel),
      ),
    ],
  );
}
