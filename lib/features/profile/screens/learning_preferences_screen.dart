import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_form_fields.dart';

class LearningPreferencesScreen extends StatelessWidget {
  const LearningPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) async {
        if (state.status == ProfileSaveStatus.saved) {
          await context.read<AuthCubit>().refreshProfile();
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('إعدادات التعلّم')),
        body: ListView(
          padding: const EdgeInsets.all(E3rabSpacing.large),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'اضبط خطتك كما يناسبك',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: E3rabSpacing.small),
                    const Text(
                      'هذه اختيارات تنظيمية؛ ترتيب إتقان الدروس ثابت ولا يتجاوز الأساسيات.',
                    ),
                    const SizedBox(height: E3rabSpacing.large),
                    const ProfileFormFields(),
                    BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (context, state) => FilledButton(
                        onPressed: state.status == ProfileSaveStatus.saving
                            ? null
                            : context.read<ProfileCubit>().save,
                        child: state.status == ProfileSaveStatus.saving
                            ? const CircularProgressIndicator()
                            : const Text('حفظ التغييرات'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
