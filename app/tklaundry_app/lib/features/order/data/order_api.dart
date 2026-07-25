import '../../../core/network/api_client.dart';
import '../../../shared/utils/tk_format.dart';
import '../domain/order_detail.dart';
import '../domain/order_list_result.dart';

class OrderApi {
  OrderApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<OrderListResult> listOrders({
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
      '/orders',
      queryParameters: queryParameters,
      fallbackMessage: '접수 목록을 불러오지 못했습니다.',
    );

    return OrderListResult.fromJson(body);
  }

  Future<List<OrderDetail>> listOrderDetails(String orderNo) async {
    final body = await _client.getList(
      '/orders/${Uri.encodeComponent(orderNo)}',
      fallbackMessage: '접수 상세를 불러오지 못했습니다.',
    );

    return body
        .map((item) => OrderDetail.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
