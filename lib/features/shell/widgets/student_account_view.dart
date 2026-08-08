import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';

class StudentAccountView extends StatelessWidget {
  const StudentAccountView({
    super.key,
    required this.onOpenSettings,
    required this.onOpenLearningPreferences,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback onOpenLearningPreferences;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final authenticated = state is AuthAuthenticated ? state : null;
        final profile = authenticated?.profile;
        final name = profile?.displayName?.trim();
        return ListView(
          padding: const EdgeInsets.all(E3rabSpacing.large),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: E3rabBrandColors.primaryContainer,
                      child: Text(
                        _initial(name),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: E3rabBrandColors.heading,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    const SizedBox(height: E3rabSpacing.medium),
                    Text(
                      name?.isNotEmpty == true ? name! : 'متعلّم إعراب',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: E3rabSpacing.xSmall),
                    Text(
                      profile?.email ?? '',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: E3rabBrandColors.muted,
                      ),
                    ),
                    const SizedBox(height: E3rabSpacing.xLarge),
                    _AccountAction(
                      icon: Icons.tune_rounded,
                      title: 'إعدادات التعلّم',
                      subtitle: 'الهدف اليومي والمستوى وطريقة عرض المحتوى',
                      onTap: onOpenLearningPreferences,
                    ),
                    const SizedBox(height: E3rabSpacing.small),
                    _AccountAction(
                      icon: Icons.shield_outlined,
                      title: 'الخصوصية والبيانات',
                      subtitle: 'إدارة تقدمك وبيانات حسابك',
                      onTap: onOpenSettings,
                    ),
                    const SizedBox(height: E3rabSpacing.xLarge),
                    OutlinedButton.icon(
                      onPressed: context.read<AuthCubit>().signOut,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('تسجيل الخروج'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _initial(String? name) {
    final value = name?.trim() ?? '';
    return value.isEmpty ? 'إ' : value.characters.first;
  }
}

class _AccountAction extends StatelessWidget {
  const _AccountAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      minTileHeight: 72,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
      onTap: onTap,
    ),
  );
}
