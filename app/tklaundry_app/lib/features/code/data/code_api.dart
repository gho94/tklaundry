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

  Future<Code> registerCode({
    required String pCodeId,
    required String codeName,
  }) async {
    final body = await _client.post(
      '/codes',
      body: {
        'pCodeId': pCodeId,
        'codeName': codeName,
      },
      fallbackMessage: '코드 등록에 실패했습니다.',
    );

    return Code.fromJson(body);
  }

  Future<void> updateCode({
    required String codeId,
    required String codeName,
  }) async {
    await _client.put(
      '/codes/${Uri.encodeComponent(codeId)}',
      body: {'codeName': codeName},
      fallbackMessage: '코드 수정에 실패했습니다.',
    );
  }

  Future<void> deleteCode(String codeId) async {
    await _client.delete(
      '/codes/${Uri.encodeComponent(codeId)}',
      fallbackMessage: '코드 삭제에 실패했습니다.',
    );
  }
}
