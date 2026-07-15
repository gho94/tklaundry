import '../../../core/network/api_client.dart';
import '../domain/member.dart';

class MemberApi {
  MemberApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<Member>> listMembers() async {
    final body = await _client.getList(
      '/members',
      fallbackMessage: '회원 목록을 불러오지 못했습니다.',
    );

    return body
        .map((item) => Member.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<bool> existsUserId(String userId) {
    return _client.getBool(
      '/members/exists',
      queryParameters: {'userId': userId.trim()},
      fallbackMessage: '아이디 중복 확인에 실패했습니다.',
    );
  }

  Future<void> updateMember({
    required String userId,
    required String userName,
    required String useYn,
    String? password,
  }) async {
    final body = <String, dynamic>{
      'userName': userName.trim(),
      'useYn': useYn,
    };
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    await _client.put(
      '/members/${Uri.encodeComponent(userId)}',
      body: body,
      fallbackMessage: '회원 수정에 실패했습니다.',
    );
  }

  Future<void> deleteMember(String userId) async {
    await _client.delete(
      '/members/${Uri.encodeComponent(userId)}',
      fallbackMessage: '회원 삭제에 실패했습니다.',
    );
  }
}
