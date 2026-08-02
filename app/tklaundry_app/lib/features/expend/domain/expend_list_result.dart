import 'expend.dart';

class ExpendListResult {
  const ExpendListResult({
    required this.items,
    required this.count,
    required this.totalAmount,
  });

  final List<Expend> items;
  final int count;
  final int totalAmount;

  static const empty = ExpendListResult(items: [], count: 0, totalAmount: 0);

  factory ExpendListResult.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return ExpendListResult(
      items: itemsJson
          .map((item) => Expend.fromJson(item as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int? ?? 0,
      totalAmount: json['totalAmount'] as int? ?? 0,
    );
  }
}
