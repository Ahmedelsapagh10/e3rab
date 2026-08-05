import 'package:flutter/material.dart';

import 'onboarding1.dart';

class OnBoarding2 extends StatelessWidget {
  const OnBoarding2({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingPageContent(
      icon: Icons.account_tree_outlined,
      title: 'شاهد الإعراب خطوة بخطوة',
      description:
          'ميّز نوع الكلمة ودورها وحالتها وعلامتها وسبب العلامة داخل المثال نفسه.',
    );
  }
}

class OnBoarding3 extends StatelessWidget {
  const OnBoarding3({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingPageContent(
      icon: Icons.task_alt_rounded,
      title: 'تقدّمك محفوظ دائمًا',
      description:
          'أنشئ حسابًا بسيطًا لتكمل من آخر خطوة وتحفظ دروسك واختباراتك على أجهزتك.',
    );
  }
}
