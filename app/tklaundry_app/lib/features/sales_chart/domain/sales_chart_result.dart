import 'sales_chart_item.dart';

class SalesChartResult {
  const SalesChartResult({
    required this.items,
    required this.count,
    required this.totalAmount,
  });

  final List<SalesChartItem> items;
  final int count;
  final int totalAmount;

  static const empty = SalesChartResult(items: [], count: 0, totalAmount: 0);

  factory SalesChartResult.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return SalesChartResult(
      items: itemsJson
          .map((item) => SalesChartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int? ?? 0,
      totalAmount: json['totalAmount'] as int? ?? 0,
    );
  }
}
