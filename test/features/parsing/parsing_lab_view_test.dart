import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/parsing/cubit/parsing_state.dart';
import 'package:new_strucuture/features/parsing/data/data_source/local_parsing_data_source.dart';
import 'package:new_strucuture/features/parsing/data/model/parsing_models.dart';
import 'package:new_strucuture/features/parsing/widgets/parsing_empty_view.dart';
import 'package:new_strucuture/features/parsing/widgets/parsing_filters_bar.dart';
import 'package:new_strucuture/features/parsing/widgets/parsing_step_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<ParsingSampleModel> samples;

  setUpAll(() async {
    samples = await AssetParsingDataSource(bundle: rootBundle).loadSamples();
  });

  testWidgets('empty lab suggests changing filters in RTL', (tester) async {
    await tester.pumpWidget(const _TestApp(child: ParsingEmptyView()));

    expect(find.textContaining('لا توجد جمل مطابقة'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(Card))),
      TextDirection.rtl,
    );
  });

  testWidgets('guided step supports large text and textual feedback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final sample = samples.first;
    final selected = sample.steps.first.correctOptionId;
    final state = ParsingState(
      status: ParsingLabStatus.ready,
      samples: [sample],
      selectedOptionId: selected,
      submitted: true,
      correctCount: 1,
    );

    await tester.pumpWidget(
      _TestApp(
        textScale: 2,
        child: ParsingStepView(
          state: state,
          onSelect: (_) {},
          onSubmit: () {},
          onNext: () {},
        ),
      ),
    );

    expect(find.text('اختيار صحيح'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chapter and level filters fit narrow large-text screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final sample = samples.firstWhere((sample) => sample.trackId == 'signs');
    final state = ParsingState(
      status: ParsingLabStatus.ready,
      samples: [sample],
      allSamples: [sample],
      selectedTrackId: sample.trackId,
    );

    await tester.pumpWidget(
      _TestApp(
        textScale: 1.8,
        child: ParsingFiltersBar(
          state: state,
          onTrackChanged: (_) {},
          onDifficultyChanged: (_) {},
        ),
      ),
    );

    expect(find.text('الباب'), findsOneWidget);
    expect(find.text('المستوى'), findsOneWidget);
    expect(find.text('علامات الإعراب'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, this.textScale = 1});

  final Widget child;
  final double textScale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    builder: (context, widget) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: widget!,
    ),
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(body: child),
    ),
  );
}
