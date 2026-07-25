class OrderDetail {
  const OrderDetail({
    required this.orderNo,
    required this.orderSeq,
    required this.productCode,
    required this.processCode,
    required this.price,
    required this.qty,
    required this.discount,
    required this.cost,
    required this.completeYn,
    this.remark,
  });

  final String orderNo;
  final int orderSeq;
  final String productCode;
  final String processCode;
  final int price;
  final int qty;
  final int discount;
  final int cost;
  final String completeYn;
  final String? remark;

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      orderNo: json['orderNo'] as String? ?? '',
      orderSeq: json['orderSeq'] as int? ?? 0,
      productCode: json['productCode'] as String? ?? '',
      processCode: json['processCode'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      discount: json['discount'] as int? ?? 0,
      qty: json['qty'] as int? ?? 0,
      cost: json['cost'] as int? ?? 0,
      completeYn: json['completeYn'] as String? ?? '',
      remark: json['remark'] as String?,
    );
  }
}
