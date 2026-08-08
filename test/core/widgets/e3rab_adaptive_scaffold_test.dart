import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/widgets/e3rab_adaptive_scaffold.dart';

void main() {
  const destinations = [
    E3rabNavigationDestination(
      label: 'الرئيسية',
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
    ),
    E3rabNavigationDestination(
      label: 'تعلّم',
      icon: Icon(Icons.school_outlined),
      selectedIcon: Icon(Icons.school),
    ),
    E3rabNavigationDestination(
      label: 'أعرب',
      icon: Icon(Icons.edit_note_outlined),
      selectedIcon: Icon(Icons.edit_note),
    ),
    E3rabNavigationDestination(
      label: 'حسابي',
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
    ),
  ];

  testWidgets('uses bottom navigation on compact layouts', (tester) async {
    await _pumpAtWidth(tester, 400, destinations);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).destinations,
      hasLength(4),
    );
  });

  for (final width in [600.0, 1024.0]) {
    testWidgets('uses four-item navigation rail at ${width.toInt()}px', (
      tester,
    ) async {
      await _pumpAtWidth(tester, width, destinations);

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).destinations,
        hasLength(4),
      );
    });
  }
}

Future<void> _pumpAtWidth(
  WidgetTester tester,
  double width,
  List<E3rabNavigationDestination> destinations,
) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: E3rabAdaptiveScaffold(
        selectedIndex: 0,
        destinations: destinations,
        onDestinationSelected: (_) {},
        body: const Center(child: Text('المحتوى')),
      ),
    ),
  );
}
