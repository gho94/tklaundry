import 'sales.dart';

class SalesListResult {
  const SalesListResult({
    required this.items,
    required this.count,
    required this.totalAmount,
  });

  final List<Sales> items;
  final int count;
  final int totalAmount;

  static const empty = SalesListResult(items: [], count: 0, totalAmount: 0);

  factory SalesListResult.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return SalesListResult(
      items: itemsJson
          .map((item) => Sales.fromJson(item as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int? ?? 0,
      totalAmount: json['totalAmount'] as int? ?? 0,
    );
  }
}
