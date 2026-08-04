import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/learning/widgets/lesson_note_dialog.dart';
import 'package:new_strucuture/features/parsing/widgets/parsing_report_dialog.dart';

void main() {
  testWidgets('lesson note controller survives the closing animation', (
    tester,
  ) async {
    String? result;
    await tester.pumpWidget(
      _DialogTestApp(
        onOpen: (context) async {
          result = await showLessonNoteDialog(context, initialText: 'قديم');
        },
      ),
    );

    await tester.tap(find.text('فتح'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ملاحظة');
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(result, 'ملاحظة');
    expect(tester.takeException(), isNull);
  });

  testWidgets('parsing report controller survives the closing animation', (
    tester,
  ) async {
    String? result;
    await tester.pumpWidget(
      _DialogTestApp(
        onOpen: (context) async {
          result = await showParsingReportDialog(context);
        },
      ),
    );

    await tester.tap(find.text('فتح'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'راجع المثال');
    await tester.tap(find.text('حفظ البلاغ'));
    await tester.pumpAndSettle();

    expect(result, 'راجع المثال');
    expect(tester.takeException(), isNull);
  });
}

class _DialogTestApp extends StatelessWidget {
  const _DialogTestApp({required this.onOpen});

  final Future<void> Function(BuildContext) onOpen;

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: FilledButton(
          onPressed: () => onOpen(context),
          child: const Text('فتح'),
        ),
      ),
    ),
  );
}
