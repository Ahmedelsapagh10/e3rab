import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DesktopAuthRestClient {
  DesktopAuthRestClient(this._client, this._apiKey);

  static const _identityBase = 'https://identitytoolkit.googleapis.com/v1';
  static const _tokenBase = 'https://securetoken.googleapis.com/v1';

  final Dio _client;
  final String _apiKey;

  Future<Map<String, dynamic>> post(
    String method,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '$_identityBase/$method?key=$_apiKey',
        data: body,
        options: Options(contentType: Headers.jsonContentType),
      );
      return response.data!;
    } on DioException catch (error) {
      final data = error.response?.data;
      final errorData = data is Map ? data['error'] : null;
      final message = errorData is Map
          ? errorData['message']?.toString()
          : null;
      throw FirebaseAuthException(
        code: _firebaseCode(message),
        message: message,
      );
    }
  }

  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final response = await _client.post<Map<String, dynamic>>(
      '$_tokenBase/token?key=$_apiKey',
      data: {'grant_type': 'refresh_token', 'refresh_token': refreshToken},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    return response.data!;
  }

  String _firebaseCode(String? value) => switch (value?.split(' : ').first) {
    'EMAIL_EXISTS' => 'email-already-in-use',
    'INVALID_LOGIN_CREDENTIALS' => 'invalid-credential',
    'WEAK_PASSWORD' => 'weak-password',
    'USER_DISABLED' => 'user-disabled',
    'EMAIL_NOT_FOUND' => 'user-not-found',
    _ => 'network-request-failed',
  };
}
