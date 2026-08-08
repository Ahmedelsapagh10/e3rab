import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/shell/widgets/home_learning_guide.dart';
import 'package:new_strucuture/features/shell/widgets/home_quick_actions.dart';

void main() {
  testWidgets('home guide and actions remain simple at large RTL text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.8)),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        ),
        home: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const HomeLearningGuide(),
              const SizedBox(height: 16),
              HomeQuickActions(
                onOpenLessons: () {},
                onOpenReference: () {},
                onOpenParsingLab: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('تعلّم بثلاث خطوات'), findsOneWidget);
    expect(find.text('الدروس'), findsOneWidget);
    expect(find.textContaining('٪'), findsNothing);
    expect(find.textContaining('إحصائ'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
