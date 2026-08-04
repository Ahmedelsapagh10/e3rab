import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/routes/app_routes.dart';
import '../../../core/design_system/e3rab_design_tokens.dart';
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
                              : 'سجّل الدخول أو واصل التعلّم كضيف.',
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
                        OutlinedButton.icon(
                          onPressed: context.read<AuthCubit>().enterGuest,
                          icon: const Icon(Icons.person_outline_rounded),
                          label: const Text('المتابعة كضيف'),
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
    if (state is AuthAuthenticated || state is AuthGuest) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.initialRoute,
        (_) => false,
      );
    }
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
            actions: const [SizedBox.shrink()],
          ),
        );
      },
    );
  }
}
