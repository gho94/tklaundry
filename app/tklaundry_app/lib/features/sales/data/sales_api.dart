import '../../../core/network/api_client.dart';
import '../../../shared/utils/tk_format.dart';
import '../domain/sales_detail.dart';
import '../domain/sales_list_result.dart';

class SalesApi {
  SalesApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<SalesListResult> listSales({
    required DateTime startDate,
    required DateTime endDate,
    String? custCode,
  }) async {
    final queryParameters = <String, String>{
      'startDate': startDate.toApiDate(),
      'endDate': endDate.toApiDate(),
    };
    if (custCode != null && custCode.isNotEmpty) {
      queryParameters['custCode'] = custCode;
    }

    final body = await _client.get(
      '/sales',
      queryParameters: queryParameters,
      fallbackMessage: '매출 목록을 불러오지 못했습니다.',
    );

    return SalesListResult.fromJson(body);
  }

  Future<List<SalesDetail>> listSalesDetails(String salesNo) async {
    final body = await _client.getList(
      '/sales/${Uri.encodeComponent(salesNo)}/details',
      fallbackMessage: '매출 상세를 불러오지 못했습니다.',
    );

    return body
        .map((item) => SalesDetail.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
