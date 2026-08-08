import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/e3rab_adaptive_scaffold.dart';
import '../../../injector.dart';
import '../../account/cubit/account_settings_cubit.dart';
import '../../account/data/account_management_repository.dart';
import '../../account/screens/account_settings_screen.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../learning/cubit/learning_cubit.dart';
import '../../learning/widgets/learning_hub_view.dart';
import '../../learning/widgets/reference_search_view.dart';
import '../../parsing/cubit/parsing_cubit.dart';
import '../../parsing/widgets/parsing_lab_view.dart';
import '../../progress/data/model/learning_progress_models.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/data/user_profile_repository.dart';
import '../../profile/screens/learning_preferences_screen.dart';
import '../../reference/cubit/reference_cubit.dart';
import '../cubit/shell_cubit.dart';
import '../widgets/e3rab_home_view.dart';
import '../widgets/shell_app_bar.dart';
import '../widgets/shell_body_transition.dart';
import '../widgets/student_account_view.dart';

const e3rabShellDestinations = [
  E3rabNavigationDestination(
    label: 'الرئيسية',
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home_rounded),
  ),
  E3rabNavigationDestination(
    label: 'الدروس',
    icon: Icon(Icons.school_outlined),
    selectedIcon: Icon(Icons.school_rounded),
  ),
  E3rabNavigationDestination(
    label: 'حسابي',
    icon: Icon(Icons.person_outline_rounded),
    selectedIcon: Icon(Icons.person_rounded),
  ),
];

class E3rabShellScreen extends StatelessWidget {
  const E3rabShellScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShellCubit(),
      child: BlocBuilder<ShellCubit, int>(
        builder: (context, selectedIndex) {
          return E3rabAdaptiveScaffold(
            selectedIndex: selectedIndex,
            destinations: e3rabShellDestinations,
            onDestinationSelected: context.read<ShellCubit>().selectDestination,
            appBar: ShellAppBar(
              selectedIndex: selectedIndex,
              onAccountTap: () => context.read<ShellCubit>().selectDestination(
                e3rabShellDestinations.length - 1,
              ),
            ),
            body: ShellBodyTransition(
              selectedIndex: selectedIndex,
              child: _body(context, selectedIndex),
            ),
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context, int index) => switch (index) {
    0 => E3rabHomeView(
      onOpenLessons: () => context.read<ShellCubit>().selectDestination(1),
      onOpenReference: () => _openReference(context),
      onOpenParsingLab: () => _openParsingLab(context),
    ),
    1 => const LearningHubView(),
    _ => StudentAccountView(
      onOpenSettings: () => _openSettings(context),
      onOpenLearningPreferences: () => _openLearningPreferences(context),
    ),
  };

  void _openReference(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<ReferenceCubit>(),
          child: const Scaffold(
            appBar: _SectionAppBar(title: 'المرجع النحوي'),
            body: ReferenceSearchView(),
          ),
        ),
      ),
    );
  }

  void _openParsingLab(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<ParsingCubit>(),
          child: const Scaffold(
            appBar: _SectionAppBar(title: 'معمل الإعراب'),
            body: ParsingLabView(),
          ),
        ),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    final learningCubit = context.read<LearningCubit>();
    final owner = LearningDataOwner.account(uid);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: learningCubit),
            BlocProvider(
              create: (_) => AccountSettingsCubit(
                serviceLocator<AccountManagementRepository>(),
                owner,
              ),
            ),
          ],
          child: const AccountSettingsScreen(isGuest: false),
        ),
      ),
    );
  }

  void _openLearningPreferences(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => ProfileCubit(
            serviceLocator<UserProfileRepository>(),
            authState.profile,
          ),
          child: const LearningPreferencesScreen(),
        ),
      ),
    );
  }
}

class _SectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SectionAppBar({required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(title: Text(title));
}
