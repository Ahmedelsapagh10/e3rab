import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/routes/app_routes.dart';
import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../../core/firebase/firebase_platform_support.dart';
import '../../../core/utils/assets_manager.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../../auth/widgets/auth_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isCreateAccount = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: _listenToAuth,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(E3rabSpacing.large),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(E3rabSpacing.xLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset(
                          ImageAssets.appIconWithoutBG,
                          height: 72,
                          semanticLabel: 'شعار إعراب',
                        ),
                        const SizedBox(height: E3rabSpacing.medium),
                        Text(
                          _isCreateAccount ? 'أنشئ حسابك' : 'مرحبًا بعودتك',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: E3rabSpacing.small),
                        Text(
                          _isCreateAccount
                              ? 'احفظ تقدمك وتابع تعلمك على أجهزتك.'
                              : 'سجّل الدخول لتكمل من آخر خطوة وصلت إليها.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: E3rabSpacing.large),
                        const _AuthStateNotice(),
                        AuthForm(
                          isCreateAccount: _isCreateAccount,
                          accountsAvailable: context
                              .read<AuthCubit>()
                              .accountsAvailable,
                          onSubmit: _submit,
                          onForgotPassword: () => Navigator.pushNamed(
                            context,
                            Routes.forgotPasswordEmailRoute,
                          ),
                        ),
                        const SizedBox(height: E3rabSpacing.large),
                        const _SocialAuthButtons(),
                        const SizedBox(height: E3rabSpacing.medium),
                        TextButton(
                          onPressed: () => setState(
                            () => _isCreateAccount = !_isCreateAccount,
                          ),
                          child: Text(
                            _isCreateAccount
                                ? 'لديك حساب؟ سجّل الدخول'
                                : 'ليس لديك حساب؟ أنشئ حسابًا',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit(AuthFormValue value) {
    final cubit = context.read<AuthCubit>();
    if (_isCreateAccount) {
      cubit.createAccount(
        email: value.email,
        password: value.password,
        displayName: value.displayName,
      );
    } else {
      cubit.signIn(email: value.email, password: value.password);
    }
  }

  void _listenToAuth(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.initialRoute,
        (_) => false,
      );
    }
  }
}

class _SocialAuthButtons extends StatelessWidget {
  const _SocialAuthButtons();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (!FirebasePlatformSupport.supportsSocialAuth) {
          return const SizedBox.shrink();
        }
        final enabled =
            context.read<AuthCubit>().accountsAvailable &&
            state is! AuthSubmitting;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'أو تابع باستخدام',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: E3rabSpacing.medium),
            OutlinedButton.icon(
              onPressed: enabled
                  ? context.read<AuthCubit>().signInWithGoogle
                  : null,
              icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
              label: const Text('Google'),
            ),
            const SizedBox(height: E3rabSpacing.small),
            OutlinedButton.icon(
              onPressed: enabled
                  ? context.read<AuthCubit>().signInWithApple
                  : null,
              icon: const Icon(Icons.apple_rounded),
              label: const Text('Apple'),
            ),
          ],
        );
      },
    );
  }
}

class _AuthStateNotice extends StatelessWidget {
  const _AuthStateNotice();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final message = switch (state) {
          AuthUnavailable unavailable => unavailable.message,
          AuthOperationFailure failure => failure.message,
          _ => null,
        };
        if (message == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: E3rabSpacing.medium),
          child: MaterialBanner(
            padding: const EdgeInsets.all(E3rabSpacing.medium),
            content: Text(message),
            actions: [
              if (state is AuthUnavailable)
                TextButton(
                  onPressed: context.read<AuthCubit>().restoreSession,
                  child: const Text('إعادة المحاولة'),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }
}
