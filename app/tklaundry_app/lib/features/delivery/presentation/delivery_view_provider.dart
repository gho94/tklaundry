import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/delivery_api.dart';
import '../domain/delivery_detail.dart';
import '../domain/delivery_list_result.dart';
import 'delivery_provider.dart';

class DeliveryViewListNotifier
    extends AutoDisposeAsyncNotifier<DeliveryListResult> {
  late final DeliveryApi _deliveryApi;

  @override
  Future<DeliveryListResult> build() async {
    _deliveryApi = DeliveryApi();
    return DeliveryListResult.empty;
  }

  Future<void> search(DeliverySearchParams params) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _deliveryApi.listDeliveries(
        startDate: params.startDate,
        endDate: params.endDate,
        custCode: params.custCode,
      ),
    );
  }
}

final deliveryViewListProvider = AsyncNotifierProvider.autoDispose<
    DeliveryViewListNotifier, DeliveryListResult>(
  DeliveryViewListNotifier.new,
);

final deliveryViewDetailListProvider =
    FutureProvider.autoDispose.family<List<DeliveryDetail>, String>(
  (ref, deliveryNo) => DeliveryApi().listDeliveryDetails(deliveryNo),
);
