class PendingPayment {
  const PendingPayment({
    required this.salesNo,
    required this.deliveryDate,
    required this.custCode,
    required this.qty,
    required this.discount,
    required this.cost,
    required this.bankingYn,
    required this.status,
  });

  final String salesNo;
  final String deliveryDate;
  final String custCode;
  final int qty;
  final int discount;
  final int cost;
  final String bankingYn;
  final String status;

  factory PendingPayment.fromJson(Map<String, dynamic> json) {
    return PendingPayment(
      salesNo: json['salesNo'] as String? ?? '',
      deliveryDate: json['deliveryDate'] as String? ?? '',
      custCode: json['custCode'] as String? ?? '',
      qty: json['qty'] as int? ?? 0,
      discount: json['discount'] as int? ?? 0,
      cost: json['cost'] as int? ?? 0,
      bankingYn: json['bankingYn'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}
