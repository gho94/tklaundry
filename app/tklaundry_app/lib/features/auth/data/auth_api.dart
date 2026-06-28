import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/auth_user.dart';

class AuthApi {
  AuthApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<AuthUser> login({
    required String userId,
    required String password,
  }) async {
    final body = await _client.post(
      '/auth/login',
      body: {'userId': userId.trim(), 'password': password},
      fallbackMessage: '로그인에 실패했습니다.',
    );

    final user = body['user'] as Map<String, dynamic>?;
    if (user == null) {
      throw ApiException(message: '로그인 응답 형식이 올바르지 않습니다.');
    }

    return AuthUser(
      userId: user['userId'] as String,
      userName: user['userName'] as String,
    );
  }
}
