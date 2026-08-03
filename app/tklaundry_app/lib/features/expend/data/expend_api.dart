import '../../../core/network/api_client.dart';
import '../../../shared/utils/tk_format.dart';
import '../domain/expend.dart';
import '../domain/expend_list_result.dart';

class ExpendApi {
  ExpendApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<ExpendListResult> listExpends({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final body = await _client.get(
      '/expends',
      queryParameters: {
        'startDate': startDate.toApiDate(),
        'endDate': endDate.toApiDate(),
      },
      fallbackMessage: '지출 목록을 불러오지 못했습니다.',
    );

    return ExpendListResult.fromJson(body);
  }

  Future<Expend> getExpend(int idx) async {
    final body = await _client.get(
      '/expends/$idx',
      fallbackMessage: '지출 상세를 불러오지 못했습니다.',
    );

    return Expend.fromJson(body);
  }

  Future<Expend> registerExpend({
    required DateTime expendDate,
    required String expendCode,
    required int cost,
    String? remark,
  }) async {
    final body = await _client.post(
      '/expends',
      body: {
        'expendDate': expendDate.toApiDate(),
        'expendCode': expendCode,
        'cost': cost,
        'remark': remark ?? '',
      },
      fallbackMessage: '지출 등록에 실패했습니다.',
    );

    return Expend.fromJson(body);
  }

  Future<void> updateExpend({
    required int idx,
    required DateTime expendDate,
    required String expendCode,
    required int cost,
    String? remark,
  }) async {
    await _client.put(
      '/expends/$idx',
      body: {
        'expendDate': expendDate.toApiDate(),
        'expendCode': expendCode,
        'cost': cost,
        'remark': remark ?? '',
      },
      fallbackMessage: '지출 수정에 실패했습니다.',
    );
  }
}
