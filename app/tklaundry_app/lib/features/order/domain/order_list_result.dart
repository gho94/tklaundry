import 'order.dart';

class OrderListResult {
  const OrderListResult({
    required this.items,
    required this.count,
    required this.totalAmount,
  });

  final List<Order> items;
  final int count;
  final int totalAmount;

  static const empty = OrderListResult(items: [], count: 0, totalAmount: 0);

  factory OrderListResult.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return OrderListResult(
      items: itemsJson
          .map((item) => Order.fromJson(item as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int? ?? 0,
      totalAmount: json['totalAmount'] as int? ?? 0,
    );
  }
}
