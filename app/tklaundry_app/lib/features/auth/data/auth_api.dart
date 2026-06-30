import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../code/domain/code.dart';
import '../domain/auth_user.dart';

class LoginResult {
  const LoginResult({
    required this.user,
    required this.codes,
  });

  final AuthUser user;
  final List<Code> codes;
}

class AuthApi {
  AuthApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<LoginResult> login({
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

    final codesBody = body['codes'] as List<dynamic>? ?? const [];
    final codes = codesBody
        .map((item) => Code.fromJson(item as Map<String, dynamic>))
        .toList();

    return LoginResult(
      user: AuthUser(
        userId: user['userId'] as String,
        userName: user['userName'] as String,
      ),
      codes: codes,
    );
  }

  Future<AuthUser> register({
    required String userId,
    required String password,
    required String userName,
    required String useYn,
  }) async {
    final body = await _client.post(
      '/auth/register',
      body: {
        'userId': userId.trim(),
        'password': password,
        'userName': userName.trim(),
        'useYn': useYn,
      },
      fallbackMessage: '회원가입에 실패했습니다.',
    );

    return AuthUser(
      userId: body['userId'] as String,
      userName: body['userName'] as String,
    );
  }

  Future<void> logout() async {
    await _client.post(
      '/auth/logout',
      fallbackMessage: '로그아웃에 실패했습니다.',
    );
  }
}
