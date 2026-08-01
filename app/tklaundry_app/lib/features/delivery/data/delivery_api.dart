import '../../../core/network/api_client.dart';
import '../../../shared/utils/tk_format.dart';
import '../../order/domain/order_detail.dart';
import '../../order/domain/order_list_result.dart';

class DeliveryApi {
  DeliveryApi({ApiClient? client}) : _client = client ?? ApiClient();

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
      '/deliveries/orders',
      queryParameters: queryParameters,
      fallbackMessage: '출고 대상 접수 목록을 불러오지 못했습니다.',
    );

    return OrderListResult.fromJson(body);
  }

  Future<List<OrderDetail>> listOrderDetails(String orderNo) async {
    final body = await _client.getList(
      '/deliveries/orders/${Uri.encodeComponent(orderNo)}/details',
      fallbackMessage: '출고 대상 접수 상세를 불러오지 못했습니다.',
    );

    return body
        .map((item) => OrderDetail.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
