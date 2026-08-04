import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/e3rab_adaptive_scaffold.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../learning/widgets/learning_catalog_view.dart';
import '../../learning/widgets/reference_search_view.dart';
import '../../learning/widgets/review_center_view.dart';
import '../../parsing/widgets/parsing_lab_view.dart';
import '../cubit/shell_cubit.dart';
import '../widgets/e3rab_home_view.dart';

class E3rabShellScreen extends StatelessWidget {
  const E3rabShellScreen({super.key, required this.isGuest});

  final bool isGuest;

  static const _destinations = [
    E3rabNavigationDestination(
      label: 'الرئيسية',
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
    ),
    E3rabNavigationDestination(
      label: 'تعلّم',
      icon: Icon(Icons.school_outlined),
      selectedIcon: Icon(Icons.school_rounded),
    ),
    E3rabNavigationDestination(
      label: 'تدرّب',
      icon: Icon(Icons.edit_note_outlined),
      selectedIcon: Icon(Icons.edit_note_rounded),
    ),
    E3rabNavigationDestination(
      label: 'المرجع',
      icon: Icon(Icons.menu_book_outlined),
      selectedIcon: Icon(Icons.menu_book_rounded),
    ),
    E3rabNavigationDestination(
      label: 'المعمل',
      icon: Icon(Icons.science_outlined),
      selectedIcon: Icon(Icons.science_rounded),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShellCubit(),
      child: BlocBuilder<ShellCubit, int>(
        builder: (context, selectedIndex) {
          return E3rabAdaptiveScaffold(
            selectedIndex: selectedIndex,
            destinations: _destinations,
            onDestinationSelected: context.read<ShellCubit>().selectDestination,
            appBar: AppBar(
              title: const Text('إعراب'),
              actions: [
                TextButton.icon(
                  onPressed: () => _accountAction(context),
                  icon: Icon(
                    isGuest ? Icons.login_rounded : Icons.logout_rounded,
                  ),
                  label: Text(isGuest ? 'تسجيل الدخول' : 'تسجيل الخروج'),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: _body(selectedIndex),
          );
        },
      ),
    );
  }

  Widget _body(int index) => switch (index) {
    0 => E3rabHomeView(isGuest: isGuest),
    1 => const LearningCatalogView(),
    2 => const ReviewCenterView(),
    3 => const ReferenceSearchView(),
    _ => const ParsingLabView(),
  };

  void _accountAction(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    if (isGuest) {
      authCubit.restoreSession();
    } else {
      authCubit.signOut();
    }
  }
}
