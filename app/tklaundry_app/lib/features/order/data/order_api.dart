import '../../../core/network/api_client.dart';
import '../../../shared/utils/tk_format.dart';
import '../domain/order.dart';
import '../domain/order_detail.dart';
import '../domain/order_list_result.dart';

class OrderDetailInput {
  const OrderDetailInput({
    required this.productCode,
    required this.processCode,
    required this.price,
    required this.qty,
    this.discount = 0,
    this.remark,
  });

  final String productCode;
  final String processCode;
  final int price;
  final int qty;
  final int discount;
  final String? remark;

  Map<String, dynamic> toJson() => {
        'productCode': productCode,
        'processCode': processCode,
        'price': price,
        'qty': qty,
        'discount': discount,
        'remark': remark,
      };
}

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

  Future<Order> registerOrder({
    required String custCode,
    required DateTime orderDate,
    required String status,
    required String bankingYn,
    required List<OrderDetailInput> details,
  }) async {
    final body = await _client.post(
      '/orders',
      body: {
        'custCode': custCode,
        'orderDate': _toApiDateTime(orderDate),
        'status': status,
        'bankingYn': bankingYn,
        'details': details.map((detail) => detail.toJson()).toList(),
      },
      fallbackMessage: '접수 등록에 실패했습니다.',
    );

    return Order.fromJson(body);
  }

  Future<void> updateOrder({
    required String orderNo,
    required String custCode,
    required DateTime orderDate,
    required String status,
    required String bankingYn,
    required List<OrderDetailInput> details,
  }) async {
    await _client.put(
      '/orders/${Uri.encodeComponent(orderNo)}',
      body: {
        'custCode': custCode,
        'orderDate': _toApiDateTime(orderDate),
        'status': status,
        'bankingYn': bankingYn,
        'details': details.map((detail) => detail.toJson()).toList(),
      },
      fallbackMessage: '접수 수정에 실패했습니다.',
    );
  }

  Future<void> deleteOrder(String orderNo) async {
    await _client.delete(
      '/orders/${Uri.encodeComponent(orderNo)}',
      fallbackMessage: '접수 삭제에 실패했습니다.',
    );
  }

  /// LocalDateTime용 ISO (`yyyy-MM-ddTHH:mm:ss`, timezone 없음).
  String _toApiDateTime(DateTime value) {
    final local = value.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)}'
        'T${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
  }
}
