import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingInitial());
  PageController pageController = PageController(initialPage: 0);
  int numPages = 3;
  double currentPage = 0;

  void changePages() {
    currentPage = pageController.page!;
    emit(ChangingPagesState());
  }

  void onPageChanged(int page) {
    currentPage = page.toDouble();
    emit(ChangingPagesState());
  }

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }
}
