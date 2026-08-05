import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/placement_quiz.dart';
import '../widgets/profile_form_fields.dart';

class LearningProfileScreen extends StatefulWidget {
  const LearningProfileScreen({super.key});

  @override
  State<LearningProfileScreen> createState() => _LearningProfileScreenState();
}

class _LearningProfileScreenState extends State<LearningProfileScreen> {
  bool _showPlacement = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileSaveStatus.saved) {
          context.read<AuthCubit>().refreshProfile();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_showPlacement ? 'اختبار تحديد المستوى' : 'إعداد مسارك'),
          leading: _showPlacement
              ? BackButton(
                  onPressed: () => setState(() => _showPlacement = false),
                )
              : null,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(E3rabSpacing.large),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: _showPlacement ? _placement() : _preferences(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _preferences() => Column(
    key: const ValueKey('preferences'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'ثلاث خطوات ونبدأ',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: E3rabSpacing.small),
      Text(
        'سنستخدم اختياراتك لبناء خطة يومية مناسبة، ويمكن تغييرها لاحقًا.',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.7,
          color: E3rabBrandColors.muted,
        ),
      ),
      const SizedBox(height: E3rabSpacing.large),
      const ProfileFormFields(),
      FilledButton.icon(
        onPressed: () => setState(() => _showPlacement = true),
        icon: const Icon(Icons.arrow_back_rounded),
        label: const Text('اختبار المستوى السريع'),
      ),
    ],
  );

  Widget _placement() => Column(
    key: const ValueKey('placement'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        '10 أسئلة فقط',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: E3rabSpacing.small),
      const Text(
        'لا توجد درجة نجاح أو رسوب؛ نريد فقط اختيار نقطة بداية مناسبة.',
      ),
      const SizedBox(height: E3rabSpacing.xLarge),
      PlacementQuiz(
        onCompleted: _complete,
        onSkipped: () => _complete('beginner'),
      ),
      BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) => state.status == ProfileSaveStatus.failure
            ? Text(
                state.message ?? 'تعذّر الحفظ.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            : const SizedBox.shrink(),
      ),
    ],
  );

  Future<void> _complete(String level) async {
    final cubit = context.read<ProfileCubit>()..selectLevel(level);
    await cubit.save();
  }
}
