import '../../../core/network/api_client.dart';
import '../../../shared/utils/tk_format.dart';
import '../domain/pending_payment.dart';
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

  Future<List<PendingPayment>> listPendingPayments({String? custCode}) async {
    final queryParameters = <String, String>{};
    if (custCode != null && custCode.isNotEmpty) {
      queryParameters['custCode'] = custCode;
    }

    final body = await _client.getList(
      '/sales/payments/pending',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
      fallbackMessage: '미수금 목록을 불러오지 못했습니다.',
    );

    return body
        .map((item) => PendingPayment.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> registerPayment({
    required String salesNo,
    required String bankingYn,
  }) async {
    await _client.post(
      '/sales/payments/${Uri.encodeComponent(salesNo)}',
      body: {'bankingYn': bankingYn},
      fallbackMessage: '미수금 결제에 실패했습니다.',
    );
  }
}
