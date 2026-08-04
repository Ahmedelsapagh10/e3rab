import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../../core/utils/assets_manager.dart';
import '../../../injector.dart';
import '../../login/screens/login_screen.dart';
import '../../curriculum/data/curriculum_repository.dart';
import '../../learning/cubit/learning_cubit.dart';
import '../../on_boarding/cubit/onboarding_cubit.dart';
import '../../on_boarding/screen/onboarding_screen.dart';
import '../../parsing/cubit/parsing_cubit.dart';
import '../../parsing/data/grammar_analysis_service.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/data/user_profile_repository.dart';
import '../../profile/screens/learning_profile_screen.dart';
import '../../progress/data/model/learning_progress_models.dart';
import '../../progress/data/progress_repository.dart';
import '../../reference/cubit/reference_cubit.dart';
import '../../reference/data/grammar_reference_repository.dart';
import '../../shell/screens/e3rab_shell_screen.dart';
import '../../sync/cubit/sync_cubit.dart';
import '../../sync/data/sync_repository.dart';
import '../../sync/widgets/guest_merge_listener.dart';
import '../../teacher/cubit/teacher_cubit.dart';
import '../../teacher/data/teacher_workspace_repository.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return switch (state) {
          AuthInitial() || AuthRestoring() => const _LaunchView(),
          AuthGuest() => _learningShell(isGuest: true),
          AuthAuthenticated authenticated => _authenticated(authenticated),
          _ => _signedOut(),
        };
      },
    );
  }

  Widget _authenticated(AuthAuthenticated state) {
    if (!state.needsOnboarding) {
      return _learningShell(isGuest: false, uid: state.user.uid);
    }
    return BlocProvider(
      key: ValueKey(state.user.uid),
      create: (_) =>
          ProfileCubit(serviceLocator<UserProfileRepository>(), state.profile),
      child: const LearningProfileScreen(),
    );
  }

  Widget _learningShell({required bool isGuest, String? uid}) {
    final owner = isGuest
        ? LearningDataOwner.guest('local-guest')
        : LearningDataOwner.account(uid!);
    final shell = E3rabShellScreen(isGuest: isGuest);
    return MultiBlocProvider(
      key: ValueKey('${owner.type.name}-${owner.id}'),
      providers: [
        BlocProvider(
          create: (_) => LearningCubit(
            serviceLocator<CurriculumRepository>(),
            serviceLocator<ProgressRepository>(),
            owner,
          )..load(),
        ),
        BlocProvider(
          create: (_) => ParsingCubit(
            serviceLocator<GrammarAnalysisService>(),
            serviceLocator<ProgressRepository>(),
            owner,
          )..load(),
        ),
        BlocProvider(
          create: (_) => ReferenceCubit(
            serviceLocator<GrammarReferenceRepository>(),
            serviceLocator<ProgressRepository>(),
            owner,
          )..load(),
        ),
        BlocProvider(
          create: (_) => TeacherCubit(
            serviceLocator<CurriculumRepository>(),
            serviceLocator<TeacherWorkspaceRepository>(),
            owner,
          )..load(),
        ),
      ],
      child: isGuest
          ? shell
          : BlocProvider(
              create: (_) => SyncCubit(
                serviceLocator<SyncRepository>(),
                LearningDataOwner.guest('local-guest'),
                owner,
              )..check(),
              child: GuestMergeListener(child: shell),
            ),
    );
  }

  Widget _signedOut() {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        return switch (state) {
          OnboardingChecking() => const _LaunchView(),
          OnboardingRequired() ||
          OnboardingPageChanged() => const OnBoardingScreen(),
          OnboardingReady() => const LoginScreen(),
        };
      },
    );
  }
}

class _LaunchView extends StatelessWidget {
  const _LaunchView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Semantics(
          label: 'جاري تجهيز تطبيق إعراب',
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                ImageAssets.appIconWithoutBG,
                width: 104,
                height: 104,
              ),
              const SizedBox(height: E3rabSpacing.large),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
