import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../order/domain/order_detail.dart';
import '../../order/domain/order_list_result.dart';
import '../data/delivery_api.dart';

class DeliverySearchParams {
  const DeliverySearchParams({
    required this.startDate,
    required this.endDate,
    this.custCode,
  });

  final DateTime startDate;
  final DateTime endDate;
  final String? custCode;
}

class DeliveryListNotifier extends AutoDisposeAsyncNotifier<OrderListResult> {
  late final DeliveryApi _deliveryApi;

  @override
  Future<OrderListResult> build() async {
    _deliveryApi = DeliveryApi();
    return OrderListResult.empty;
  }

  Future<void> search(DeliverySearchParams params) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _deliveryApi.listOrders(
        startDate: params.startDate,
        endDate: params.endDate,
        custCode: params.custCode,
      ),
    );
  }
}

final deliveryListProvider =
    AsyncNotifierProvider.autoDispose<DeliveryListNotifier, OrderListResult>(
  DeliveryListNotifier.new,
);

final deliveryDetailListProvider =
    FutureProvider.autoDispose.family<List<OrderDetail>, String>(
  (ref, orderNo) => DeliveryApi().listOrderDetails(orderNo),
);
