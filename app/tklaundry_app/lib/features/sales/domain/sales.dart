class Sales {
  const Sales({
    required this.salesNo,
    required this.salesDate,
    required this.custCode,
    required this.qty,
    required this.discount,
    required this.cost,
    required this.bankingYn,
    required this.status,
    required this.salesYn,
  });

  final String salesNo;
  final String salesDate;
  final String custCode;
  final int qty;
  final int discount;
  final int cost;
  final String bankingYn;
  final String status;
  final String salesYn;

  factory Sales.fromJson(Map<String, dynamic> json) {
    return Sales(
      salesNo: json['salesNo'] as String? ?? '',
      salesDate: json['salesDate'] as String? ?? '',
      custCode: json['custCode'] as String? ?? '',
      qty: json['qty'] as int? ?? 0,
      discount: json['discount'] as int? ?? 0,
      cost: json['cost'] as int? ?? 0,
      bankingYn: json['bankingYn'] as String? ?? '',
      status: json['status'] as String? ?? '',
      salesYn: json['salesYn'] as String? ?? '',
    );
  }
}
