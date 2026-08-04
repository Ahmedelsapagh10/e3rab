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
  ];

  testWidgets('uses bottom navigation on compact layouts', (tester) async {
    await _pumpAtWidth(tester, 400, destinations);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('uses navigation rail on expanded layouts', (tester) async {
    await _pumpAtWidth(tester, 1200, destinations);

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
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
