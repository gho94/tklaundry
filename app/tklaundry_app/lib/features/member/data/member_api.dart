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
}
