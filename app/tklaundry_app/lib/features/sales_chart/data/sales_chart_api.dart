import '../../../core/network/api_client.dart';
import '../../../shared/utils/tk_format.dart';
import '../domain/chart_unit.dart';
import '../domain/sales_chart_daily_result.dart';
import '../domain/sales_chart_result.dart';

class SalesChartApi {
  SalesChartApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<SalesChartResult> getChart({
    required DateTime startDate,
    required DateTime endDate,
    required ChartUnit unit,
  }) async {
    final body = await _client.get(
      '/sales/chart',
      queryParameters: {
        'startDate': startDate.toApiDate(),
        'endDate': endDate.toApiDate(),
        'unit': unit.apiValue,
      },
      fallbackMessage: '매출현황을 불러오지 못했습니다.',
    );

    return SalesChartResult.fromJson(body);
  }

  Future<SalesChartDailyResult> listDailyItems({
    required DateTime salesDate,
  }) async {
    final body = await _client.get(
      '/sales/chart/daily',
      queryParameters: {
        'salesDate': salesDate.toApiDate(),
      },
      fallbackMessage: '일매출 상세를 불러오지 못했습니다.',
    );

    return SalesChartDailyResult.fromJson(body);
  }
}
