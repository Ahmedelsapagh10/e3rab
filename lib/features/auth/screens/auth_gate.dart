import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../../core/utils/assets_manager.dart';
import '../../../injector.dart';
import '../../login/screens/login_screen.dart';
import '../../curriculum/data/curriculum_repository.dart';
import '../../learning/cubit/learning_cubit.dart';
import '../../curriculum/data/grammar_coverage_repository.dart';
import '../../on_boarding/cubit/onboarding_cubit.dart';
import '../../on_boarding/screen/onboarding_screen.dart';
import '../../parsing/cubit/parsing_cubit.dart';
import '../../parsing/data/grammar_analysis_service.dart';
import '../../progress/data/model/learning_progress_models.dart';
import '../../progress/data/progress_repository.dart';
import '../../reference/cubit/reference_cubit.dart';
import '../../reference/data/grammar_reference_repository.dart';
import '../../shell/screens/e3rab_shell_screen.dart';
import '../../sync/cubit/sync_cubit.dart';
import '../../sync/data/sync_repository.dart';
import '../../sync/widgets/guest_merge_listener.dart';
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
          AuthAuthenticated authenticated => _learningShell(
            uid: authenticated.user.uid,
          ),
          _ => _signedOut(),
        };
      },
    );
  }

  Widget _learningShell({required String uid}) {
    final owner = LearningDataOwner.account(uid);
    final guestOwner = LearningDataOwner.guest('local-guest');
    final shell = E3rabShellScreen(uid: uid);
    return MultiBlocProvider(
      key: ValueKey('${owner.type.name}-${owner.id}'),
      providers: [
        BlocProvider(
          create: (_) => LearningCubit(
            serviceLocator<CurriculumRepository>(),
            serviceLocator<ProgressRepository>(),
            owner,
            coverageRepository: serviceLocator<GrammarCoverageRepository>(),
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
      ],
      child: BlocProvider(
        create: (_) =>
            SyncCubit(serviceLocator<SyncRepository>(), guestOwner, owner)
              ..check(),
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
