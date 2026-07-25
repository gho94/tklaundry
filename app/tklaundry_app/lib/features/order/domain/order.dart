class Order {
  const Order({
    required this.orderNo,
    required this.orderDate,
    required this.custCode,
    required this.qty,
    required this.discount,
    required this.cost,
    required this.status,
    this.deliveryDate,
    required this.bankingYn,
    required this.completeYn,
  });

  final String orderNo;
  final String orderDate;
  final String custCode;
  final int qty;
  final int discount;
  final int cost;
  final String status;
  final String? deliveryDate;
  final String bankingYn;
  final String completeYn;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderNo: json['orderNo'] as String? ?? '',
      orderDate: json['orderDate'] as String? ?? '',
      custCode: json['custCode'] as String? ?? '',
      qty: json['qty'] as int? ?? 0,
      discount: json['discount'] as int? ?? 0,
      cost: json['cost'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      deliveryDate: json['deliveryDate'] as String?,
      bankingYn: json['bankingYn'] as String? ?? '',
      completeYn: json['completeYn'] as String? ?? '',
    );
  }
}
