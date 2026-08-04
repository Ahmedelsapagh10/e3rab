class SendCodeRequest {
  final String email;

  SendCodeRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class VerifyCodeRequest {
  final String email;
  final String code;

  VerifyCodeRequest({
    required this.email,
    required this.code,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
    };
  }
}

class ResetPasswordRequest {
  final String email;
  final String code;
  final String newPassword;
  final String confirmPassword;

  ResetPasswordRequest({
    required this.email,
    required this.code,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
      'new_password': newPassword,
      'new_password_confirmation': confirmPassword,
    };
  }
}

class ForgotPasswordResetArgs {
  final String email;
  final String code;

  ForgotPasswordResetArgs({
    required this.email,
    required this.code,
  });
}

class ForgetPasswordResponse {
  final bool success;
  final String message;

  ForgetPasswordResponse({
    required this.success,
    required this.message,
  });

  factory ForgetPasswordResponse.fromJson(Map<String, dynamic> json) {
    final String resolvedMessage = (json['message'] ??
            json['msg'] ??
            json['error'] ??
            'Something went wrong.')
        .toString();

    return ForgetPasswordResponse(
      success: json['success'] ?? false,
      message: resolvedMessage,
    );
  }
}
