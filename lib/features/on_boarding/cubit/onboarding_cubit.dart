import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/onboarding_repository.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._repository) : super(OnboardingChecking());

  final OnboardingRepository _repository;
  final PageController pageController = PageController();
  static const numPages = 3;
  int currentPage = 0;

  void restore() {
    emit(_repository.isCompleted ? OnboardingReady() : OnboardingRequired());
  }

  void onPageChanged(int page) {
    currentPage = page;
    emit(OnboardingPageChanged());
  }

  Future<void> complete() async {
    await _repository.complete();
    emit(OnboardingReady());
  }

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }
}
