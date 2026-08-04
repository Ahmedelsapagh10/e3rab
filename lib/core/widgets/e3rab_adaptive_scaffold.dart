import 'package:flutter/material.dart';

import '../design_system/e3rab_design_tokens.dart';

class E3rabNavigationDestination {
  const E3rabNavigationDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final Widget icon;
  final Widget selectedIcon;
}

class E3rabAdaptiveScaffold extends StatelessWidget {
  const E3rabAdaptiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.body,
    this.appBar,
    this.floatingActionButton,
  });

  final int selectedIndex;
  final List<E3rabNavigationDestination> destinations;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    assert(destinations.isNotEmpty);
    assert(selectedIndex >= 0 && selectedIndex < destinations.length);
    final width = MediaQuery.sizeOf(context).width;

    if (E3rabBreakpoints.isCompact(width)) {
      return Scaffold(
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: destinations.map(_bottomDestination).toList(),
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              selectedIndex: selectedIndex,
              extended: E3rabBreakpoints.isExpanded(width),
              onDestinationSelected: onDestinationSelected,
              destinations: destinations.map(_railDestination).toList(),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }

  NavigationDestination _bottomDestination(
    E3rabNavigationDestination destination,
  ) {
    return NavigationDestination(
      icon: destination.icon,
      selectedIcon: destination.selectedIcon,
      label: destination.label,
    );
  }

  NavigationRailDestination _railDestination(
    E3rabNavigationDestination destination,
  ) {
    return NavigationRailDestination(
      icon: destination.icon,
      selectedIcon: destination.selectedIcon,
      label: Text(destination.label),
    );
  }
}
