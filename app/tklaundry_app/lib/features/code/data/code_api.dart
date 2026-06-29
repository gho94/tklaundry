import '../../../core/network/api_client.dart';
import '../domain/code.dart';

class CodeApi {
  CodeApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<Code>> listCodes() async {
    final body = await _client.getList(
      '/codes',
      fallbackMessage: '코드 목록을 불러오지 못했습니다.',
    );

    return body
        .map((item) => Code.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Code> getCode(String codeId) async {
    final body = await _client.get(
      '/codes/${Uri.encodeComponent(codeId)}',
      fallbackMessage: '코드 정보를 불러오지 못했습니다.',
    );

    return Code.fromJson(body);
  }
}
