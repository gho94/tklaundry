class SalesChartItem {
  const SalesChartItem({
    required this.salesDate,
    required this.cost,
  });

  final String salesDate;
  final int cost;

  factory SalesChartItem.fromJson(Map<String, dynamic> json) {
    return SalesChartItem(
      salesDate: json['salesDate'] as String? ?? '',
      cost: json['cost'] as int? ?? 0,
    );
  }
}
