import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/order_api.dart';
import '../domain/order_detail.dart';
import '../domain/order_list_result.dart';

class OrderSearchParams {
  const OrderSearchParams({
    required this.startDate,
    required this.endDate,
    this.custCode,
  });

  final DateTime startDate;
  final DateTime endDate;
  final String? custCode;
}

class OrderListNotifier extends AutoDisposeAsyncNotifier<OrderListResult> {
  late final OrderApi _orderApi;

  @override
  Future<OrderListResult> build() async {
    _orderApi = OrderApi();
    return OrderListResult.empty;
  }

  Future<void> search(OrderSearchParams params) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _orderApi.listOrders(
        startDate: params.startDate,
        endDate: params.endDate,
        custCode: params.custCode,
      ),
    );
  }
}

final orderListProvider =
    AsyncNotifierProvider.autoDispose<OrderListNotifier, OrderListResult>(
  OrderListNotifier.new,
);

final orderDetailListProvider =
    FutureProvider.autoDispose.family<List<OrderDetail>, String>(
  (ref, orderNo) => OrderApi().listOrderDetails(orderNo),
);
