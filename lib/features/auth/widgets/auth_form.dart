import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class AuthFormValue {
  const AuthFormValue({
    required this.email,
    required this.password,
    this.displayName,
  });

  final String email;
  final String password;
  final String? displayName;
}

class AuthForm extends StatefulWidget {
  const AuthForm({
    super.key,
    required this.isCreateAccount,
    required this.accountsAvailable,
    required this.onSubmit,
    required this.onForgotPassword,
  });

  final bool isCreateAccount;
  final bool accountsAvailable;
  final ValueChanged<AuthFormValue> onSubmit;
  final VoidCallback onForgotPassword;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.isCreateAccount) ...[
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) => value?.trim().isEmpty == true
                    ? 'اكتب الاسم الذي تريد ظهوره.'
                    : null,
              ),
              const SizedBox(height: E3rabSpacing.medium),
            ],
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: _validateEmail,
            ),
            const SizedBox(height: E3rabSpacing.medium),
            TextFormField(
              controller: _passwordController,
              obscureText: !_showPassword,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _showPassword
                      ? 'إخفاء كلمة المرور'
                      : 'إظهار كلمة المرور',
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                ),
              ),
              validator: (value) => (value?.length ?? 0) < 8
                  ? 'يجب ألا تقل كلمة المرور عن 8 أحرف.'
                  : null,
            ),
            if (!widget.isCreateAccount)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: widget.accountsAvailable
                      ? widget.onForgotPassword
                      : null,
                  child: const Text('نسيت كلمة المرور؟'),
                ),
              )
            else
              const SizedBox(height: E3rabSpacing.medium),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final loading = state is AuthSubmitting;
                return FilledButton(
                  onPressed: loading || !widget.accountsAvailable
                      ? null
                      : _submit,
                  child: loading
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          widget.isCreateAccount
                              ? 'إنشاء الحساب'
                              : 'تسجيل الدخول',
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    final valid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
    return valid ? null : 'أدخل بريدًا إلكترونيًا صحيحًا.';
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    widget.onSubmit(
      AuthFormValue(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: widget.isCreateAccount
            ? _nameController.text.trim()
            : null,
      ),
    );
  }
}
