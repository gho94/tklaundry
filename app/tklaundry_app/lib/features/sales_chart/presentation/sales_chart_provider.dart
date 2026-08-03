import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sales_chart_api.dart';
import '../domain/chart_unit.dart';
import '../domain/sales_chart_result.dart';

class SalesChartSearchParams {
  const SalesChartSearchParams({
    required this.startDate,
    required this.endDate,
    required this.unit,
  });

  final DateTime startDate;
  final DateTime endDate;
  final ChartUnit unit;
}

class SalesChartNotifier extends AutoDisposeAsyncNotifier<SalesChartResult> {
  late final SalesChartApi _salesChartApi;

  @override
  Future<SalesChartResult> build() async {
    _salesChartApi = SalesChartApi();
    return SalesChartResult.empty;
  }

  Future<void> search(SalesChartSearchParams params) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _salesChartApi.getChart(
        startDate: params.startDate,
        endDate: params.endDate,
        unit: params.unit,
      ),
    );
  }
}

final salesChartProvider = AsyncNotifierProvider.autoDispose<
    SalesChartNotifier, SalesChartResult>(
  SalesChartNotifier.new,
);
