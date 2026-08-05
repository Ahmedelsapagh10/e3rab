import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../learning/cubit/learning_cubit.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../cubit/account_settings_cubit.dart';
import '../cubit/account_settings_state.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/settings_action_card.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key, required this.isGuest});

  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountSettingsCubit, AccountSettingsState>(
      listener: _listen,
      child: Scaffold(
        appBar: AppBar(title: const Text('الخصوصية والبيانات')),
        body: ListView(
          padding: const EdgeInsets.all(E3rabSpacing.large),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: BlocBuilder<AccountSettingsCubit, AccountSettingsState>(
                  builder: (context, state) {
                    final working =
                        state.status == AccountSettingsStatus.working;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _PrivacySummary(),
                        const SizedBox(height: E3rabSpacing.large),
                        SettingsActionCard(
                          icon: Icons.restart_alt_rounded,
                          title: 'إعادة ضبط التقدم',
                          description:
                              'يمسح إنجاز الدروس والمحاولات والإتقان والمراجعات، مع الاحتفاظ بالمحفوظات والملاحظات.',
                          actionLabel: 'إعادة ضبط التقدم',
                          onPressed: working
                              ? null
                              : () => _confirmReset(context),
                        ),
                        if (!isGuest) ...[
                          const SizedBox(height: E3rabSpacing.large),
                          SettingsActionCard(
                            icon: Icons.delete_forever_outlined,
                            title: 'حذف الحساب والبيانات',
                            description:
                                'يحذف بيانات الحساب الخاصة من Firebase ثم يحذف حساب تسجيل الدخول بعد تأكيد كلمة المرور.',
                            actionLabel: 'حذف الحساب',
                            destructive: true,
                            onPressed: working
                                ? null
                                : () => _confirmDeletion(context),
                          ),
                        ],
                        if (working) ...[
                          const SizedBox(height: E3rabSpacing.large),
                          const Center(child: CircularProgressIndicator()),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _listen(BuildContext context, AccountSettingsState state) {
    if (state.status == AccountSettingsStatus.progressReset) {
      context.read<LearningCubit>().load();
    }
    if (state.message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message!)));
    }
    if (state.status == AccountSettingsStatus.accountDeleted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إعادة ضبط التقدم؟'),
        content: const Text('ستبدأ الدروس والتمارين من جديد.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AccountSettingsCubit>().resetProgress();
    }
  }

  Future<void> _confirmDeletion(BuildContext context) async {
    final authState = context.read<AuthCubit>().state;
    final providers = authState is AuthAuthenticated
        ? authState.profile.authProviders
        : const <String>[];
    if (!providers.contains('password')) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('حذف الحساب نهائيًا؟'),
          content: const Text(
            'سنطلب تأكيد Google أو Apple، ثم نحذف الحساب وكل بيانات التعلّم.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('متابعة الحذف'),
            ),
          ],
        ),
      );
      if (confirmed == true && context.mounted) {
        await context.read<AccountSettingsCubit>().deleteAccount('');
      }
      return;
    }
    final password = await showDialog<String>(
      context: context,
      builder: (_) => const DeleteAccountDialog(),
    );
    if (password != null && context.mounted) {
      await context.read<AccountSettingsCubit>().deleteAccount(password);
    }
  }
}

class _PrivacySummary extends StatelessWidget {
  const _PrivacySummary();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(E3rabSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('بياناتك خاصة', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'لا توجد ملفات عامة أو محادثات أو إعلانات. ملاحظاتك لا تُرسل للتحليلات، ووصول Firebase مقصور على معرّف حسابك.',
            style: TextStyle(height: 1.7),
          ),
        ],
      ),
    ),
  );
}
