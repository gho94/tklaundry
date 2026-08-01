class Delivery {
  const Delivery({
    required this.deliveryNo,
    required this.orderDate,
    required this.custCode,
    required this.qty,
    required this.discount,
    required this.cost,
    required this.bankingYn,
    required this.status,
    required this.deliveryDate,
  });

  final String deliveryNo;
  final String orderDate;
  final String custCode;
  final int qty;
  final int discount;
  final int cost;
  final String bankingYn;
  final String status;
  final String deliveryDate;

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      deliveryNo: json['deliveryNo'] as String? ?? '',
      orderDate: json['orderDate'] as String? ?? '',
      custCode: json['custCode'] as String? ?? '',
      qty: json['qty'] as int? ?? 0,
      discount: json['discount'] as int? ?? 0,
      cost: json['cost'] as int? ?? 0,
      bankingYn: json['bankingYn'] as String? ?? '',
      status: json['status'] as String? ?? '',
      deliveryDate: json['deliveryDate'] as String? ?? '',
    );
  }
}
