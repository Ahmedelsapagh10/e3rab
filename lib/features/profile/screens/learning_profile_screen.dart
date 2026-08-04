import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_form_fields.dart';

class LearningProfileScreen extends StatelessWidget {
  const LearningProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileSaveStatus.saved) {
          context.read<AuthCubit>().refreshProfile();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('إعداد مسارك')),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(E3rabSpacing.large),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'لنصنع مسارًا مناسبًا لك',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: E3rabSpacing.small),
                    Text(
                      'اختر المستوى الأقرب لك الآن، ويمكنك تعديل هذه الاختيارات لاحقًا من ملف التعلم.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(height: 1.7),
                    ),
                    const SizedBox(height: E3rabSpacing.large),
                    const ProfileFormFields(),
                    BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (state.status == ProfileSaveStatus.failure)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  state.message ?? 'تعذّر الحفظ.',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            FilledButton(
                              onPressed:
                                  state.status == ProfileSaveStatus.saving
                                  ? null
                                  : context.read<ProfileCubit>().save,
                              child: state.status == ProfileSaveStatus.saving
                                  ? const CircularProgressIndicator()
                                  : const Text('حفظ وبدء التعلّم'),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
