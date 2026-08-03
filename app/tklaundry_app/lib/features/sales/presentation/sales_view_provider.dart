import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sales_api.dart';
import '../domain/sales_detail.dart';
import '../domain/sales_list_result.dart';

class SalesSearchParams {
  const SalesSearchParams({
    required this.startDate,
    required this.endDate,
    this.custCode,
  });

  final DateTime startDate;
  final DateTime endDate;
  final String? custCode;
}

class SalesViewListNotifier extends AutoDisposeAsyncNotifier<SalesListResult> {
  late final SalesApi _salesApi;

  @override
  Future<SalesListResult> build() async {
    _salesApi = SalesApi();
    return SalesListResult.empty;
  }

  Future<void> search(SalesSearchParams params) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _salesApi.listSales(
        startDate: params.startDate,
        endDate: params.endDate,
        custCode: params.custCode,
      ),
    );
  }
}

final salesViewListProvider = AsyncNotifierProvider.autoDispose<
    SalesViewListNotifier, SalesListResult>(
  SalesViewListNotifier.new,
);

final salesViewDetailListProvider =
    FutureProvider.autoDispose.family<List<SalesDetail>, String>(
  (ref, salesNo) => SalesApi().listSalesDetails(salesNo),
);
