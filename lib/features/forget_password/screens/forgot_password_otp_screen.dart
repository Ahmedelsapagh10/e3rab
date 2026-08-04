import 'package:easy_localization/easy_localization.dart';
import 'package:new_strucuture/core/exports.dart';
import 'package:new_strucuture/config/themes/theme_helper.dart';
import 'package:new_strucuture/config/routes/app_routes.dart';
import 'package:new_strucuture/features/forget_password/data/model/forget_password_model.dart';
import '../cubit/cubit.dart';
import '../cubit/state.dart';
import 'package:pinput/pinput.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  const ForgotPasswordOtpScreen({super.key});

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  String _otpCode = '';

  void _verify(String email) {
    if (_otpCode.length == 4) {
      context.read<ForgetPasswordCubit>().verifyCode(email, _otpCode);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("verification_code_invalid".tr()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)!.settings.arguments as String;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 600;

    final colors = ThemeHelper.colorsOf(context);
    final scaffoldBg = colors.background2;
    final cardBg = colors.surface;
    final cardBorder = colors.borderColor;
    final primaryTextColor = colors.textPrimary;

    final defaultPinTheme = PinTheme(
      width: 56.w,
      height: 64.h,
      textStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: colors.black,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder, width: 1.5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primary, width: 1.5),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: cardBorder, width: 1.5),
    );

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
            if (state is ForgetPasswordCodeVerified) {
              Navigator.pushNamed(
                context,
                Routes.forgotPasswordResetRoute,
                arguments: ForgotPasswordResetArgs(
                  email: state.email,
                  code: state.code,
                ),
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
                            Icons.mark_email_read_outlined,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Text Header
                      Center(
                        child: Text(
                          "verification_code".tr(),
                          style: getBoldStyle(
                            fontSize: 22.0,
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          "enter_verification_code".tr(),
                          style: getRegularStyle(
                            fontSize: 13.0,
                            color: AppColors.greya8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // OTP custom widget fields
                      Pinput(
                        length: 4,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: submittedPinTheme,
                        validator: (s) {
                          return s?.length == 4
                              ? null
                              : 'verification_code_invalid'.tr();
                        },
                        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                        showCursor: true,
                        onCompleted: (pin) {
                          setState(() {
                            _otpCode = pin;
                          });
                          _verify(email);
                        },
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => _verify(email),
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
                                  "verify_code".tr(),
                                  style: getBoldStyle(
                                    fontSize: 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Resend Code Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    context
                                        .read<ForgetPasswordCubit>()
                                        .sendCode(email);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('reset_link_sent'.tr()),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: AppColors.success59,
                                      ),
                                    );
                                  },
                            child: Text(
                              "resend_code".tr(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
