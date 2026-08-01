import '../../../core/network/api_client.dart';
import '../../../shared/utils/tk_format.dart';
import '../../order/domain/order_detail.dart';
import '../../order/domain/order_list_result.dart';

class DeliveryDetailInput {
  const DeliveryDetailInput({
    required this.orderSeq,
    required this.productCode,
    required this.processCode,
    required this.price,
    required this.qty,
    required this.discount,
    required this.cost,
    this.remark,
  });

  final int orderSeq;
  final String productCode;
  final String processCode;
  final int price;
  final int qty;
  final int discount;
  final int cost;
  final String? remark;

  factory DeliveryDetailInput.fromOrderDetail(OrderDetail detail) {
    return DeliveryDetailInput(
      orderSeq: detail.orderSeq,
      productCode: detail.productCode,
      processCode: detail.processCode,
      price: detail.price,
      qty: detail.qty,
      discount: detail.discount,
      cost: detail.cost,
      remark: detail.remark,
    );
  }

  Map<String, dynamic> toJson() => {
        'orderSeq': orderSeq,
        'productCode': productCode,
        'processCode': processCode,
        'price': price,
        'qty': qty,
        'discount': discount,
        'cost': cost,
        'remark': remark,
      };
}

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

  Future<void> registerDelivery({
    required String orderNo,
    required String orderDate,
    required String custCode,
    required String orderStatus,
    required String status,
    required String bankingYn,
    required List<DeliveryDetailInput> details,
  }) async {
    await _client.post(
      '/deliveries',
      body: {
        'orderNo': orderNo,
        'orderDate': orderDate,
        'custCode': custCode,
        'orderStatus': orderStatus,
        'status': status,
        'bankingYn': bankingYn,
        'details': details.map((detail) => detail.toJson()).toList(),
      },
      fallbackMessage: '출고 등록에 실패했습니다.',
    );
  }
}
