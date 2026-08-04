part of 'onboarding_cubit.dart';

@immutable
sealed class OnboardingState {}

final class OnboardingChecking extends OnboardingState {}

final class OnboardingRequired extends OnboardingState {}

final class OnboardingReady extends OnboardingState {}

final class OnboardingPageChanged extends OnboardingState {}
