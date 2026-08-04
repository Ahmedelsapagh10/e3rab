import 'package:easy_localization/easy_localization.dart';
import 'package:new_strucuture/core/exports.dart';
import 'package:new_strucuture/config/themes/theme_helper.dart';
import 'package:new_strucuture/config/routes/app_routes.dart';
import '../cubit/cubit.dart';
import '../cubit/state.dart';

import 'package:intl_phone_field/intl_phone_field.dart';

class ForgotPasswordEmailScreen extends StatefulWidget {
  const ForgotPasswordEmailScreen({super.key});

  @override
  State<ForgotPasswordEmailScreen> createState() =>
      _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState extends State<ForgotPasswordEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _completePhoneNumber = '';
  bool _isPhoneNumber = false; // Control flag for phone number mode

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final value = _isPhoneNumber
          ? _completePhoneNumber.trim()
          : _emailController.text.trim();
      context.read<ForgetPasswordCubit>().sendCode(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 600;

    final colors = ThemeHelper.colorsOf(context);
    final scaffoldBg = colors.background2;
    final cardBg = colors.surface;
    final cardBorder = colors.borderColor;
    final textColor = colors.black;
    final primaryTextColor = colors.textPrimary;
    final fieldBg = colors.background;
    final fieldBorder = colors.borderColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
          listener: (context, state) {
            if (state is ForgetPasswordCodeSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('reset_link_sent'.tr()),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.success59,
                ),
              );
              Navigator.pushNamed(
                context,
                Routes.forgotPasswordOtpRoute,
                arguments: state.email,
              );
            } else if (state is ForgetPasswordError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is ForgetPasswordLoading;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 400.0 : double.infinity,
                  ),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cardBorder, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Icon Header
                        Center(
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Text Header
                        Center(
                          child: Text(
                            "forgot_password_title".tr(),
                            style: getBoldStyle(
                              fontSize: 22.0,
                              color: primaryTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            "forgot_password_subtitle".tr(),
                            style: getRegularStyle(
                              fontSize: 13.0,
                              color: AppColors.greya8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Toggle Selector Row
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isPhoneNumber = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: !_isPhoneNumber
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "email".tr(),
                                      style: getBoldStyle(
                                        fontSize: 13.0,
                                        color: !_isPhoneNumber
                                            ? AppColors.primary
                                            : AppColors.greya8,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isPhoneNumber = true;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: _isPhoneNumber
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Phone Number",
                                      style: getBoldStyle(
                                        fontSize: 13.0,
                                        color: _isPhoneNumber
                                            ? AppColors.primary
                                            : AppColors.greya8,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        if (!_isPhoneNumber) ...[
                          // Email Field Label
                          Text(
                            "email".tr(),
                            style: getBoldStyle(
                              fontSize: 13.0,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            enabled: !isLoading,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(fontSize: 14, color: textColor),
                            decoration: InputDecoration(
                              hintText: "enter_email".tr(),
                              hintStyle: const TextStyle(
                                fontSize: 13,
                                color: AppColors.greya8,
                              ),
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                size: 20,
                                color: AppColors.greya8,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              filled: true,
                              fillColor: fieldBg,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: fieldBorder,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.red,
                                  width: 1,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.red,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "email_required".tr();
                              }
                              final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                              if (!regex.hasMatch(value.trim())) {
                                return "email_invalid".tr();
                              }
                              return null;
                            },
                          ),
                        ] else ...[
                          // Phone Field Label
                          Text(
                            "Phone Number",
                            style: getBoldStyle(
                              fontSize: 13.0,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          IntlPhoneField(
                            controller: _phoneController,
                            enabled: !isLoading,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(fontSize: 14, color: textColor),
                            dropdownTextStyle: TextStyle(
                              fontSize: 14,
                              color: textColor,
                            ),
                            initialCountryCode: 'EG',
                            disableLengthCheck: true,
                            decoration: InputDecoration(
                              hintText: "Enter your phone number",
                              hintStyle: const TextStyle(
                                fontSize: 13,
                                color: AppColors.greya8,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              filled: true,
                              fillColor: fieldBg,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: fieldBorder,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.red,
                                  width: 1,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.red,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            validator: (phone) {
                              if (phone == null ||
                                  phone.number.trim().isEmpty) {
                                return "Phone number is required";
                              }
                              final number = phone.number.trim();
                              if (phone.countryISOCode == 'EG') {
                                final hasLeadingZero = number.startsWith('0');
                                final checkNumber = hasLeadingZero
                                    ? number
                                    : '0$number';
                                final validPrefixes = [
                                  '010',
                                  '011',
                                  '012',
                                  '015',
                                ];
                                bool isValidPrefix = false;
                                for (var prefix in validPrefixes) {
                                  if (checkNumber.startsWith(prefix)) {
                                    isValidPrefix = true;
                                    break;
                                  }
                                }
                                if (!isValidPrefix) {
                                  return "Number must start with 010, 011, 012, or 015";
                                }
                                final expectedLength = hasLeadingZero ? 11 : 10;
                                if (number.length != expectedLength) {
                                  return "Egypt phone number must be $expectedLength digits";
                                }
                              } else {
                                if (number.length < 7 || number.length > 15) {
                                  return "Invalid phone number length";
                                }
                              }
                              return null;
                            },
                            onChanged: (phone) {
                              _completePhoneNumber = phone.completeNumber;
                            },
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.primary
                                  .withValues(alpha: 0.6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "send_code".tr(),
                                    style: getBoldStyle(
                                      fontSize: 14.0,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
