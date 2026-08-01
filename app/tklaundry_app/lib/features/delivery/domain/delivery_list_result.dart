import 'delivery.dart';

class DeliveryListResult {
  const DeliveryListResult({
    required this.items,
    required this.count,
    required this.totalAmount,
  });

  final List<Delivery> items;
  final int count;
  final int totalAmount;

  static const empty = DeliveryListResult(items: [], count: 0, totalAmount: 0);

  factory DeliveryListResult.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return DeliveryListResult(
      items: itemsJson
          .map((item) => Delivery.fromJson(item as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int? ?? 0,
      totalAmount: json['totalAmount'] as int? ?? 0,
    );
  }
}
