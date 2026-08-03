import 'sales_chart_daily_item.dart';

class SalesChartDailyResult {
  const SalesChartDailyResult({
    required this.items,
    required this.count,
    required this.totalAmount,
  });

  final List<SalesChartDailyItem> items;
  final int count;
  final int totalAmount;

  static const empty =
      SalesChartDailyResult(items: [], count: 0, totalAmount: 0);

  factory SalesChartDailyResult.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return SalesChartDailyResult(
      items: itemsJson
          .map((item) =>
              SalesChartDailyItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int? ?? 0,
      totalAmount: json['totalAmount'] as int? ?? 0,
    );
  }
}
