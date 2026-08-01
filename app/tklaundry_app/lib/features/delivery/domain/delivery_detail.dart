class DeliveryDetail {
  const DeliveryDetail({
    required this.deliveryNo,
    required this.deliverySeq,
    required this.productCode,
    required this.processCode,
    required this.price,
    required this.qty,
    required this.discount,
    required this.cost,
    required this.orderNo,
    required this.orderSeq,
    this.remark,
  });

  final String deliveryNo;
  final int deliverySeq;
  final String productCode;
  final String processCode;
  final int price;
  final int qty;
  final int discount;
  final int cost;
  final String orderNo;
  final int orderSeq;
  final String? remark;

  factory DeliveryDetail.fromJson(Map<String, dynamic> json) {
    return DeliveryDetail(
      deliveryNo: json['deliveryNo'] as String? ?? '',
      deliverySeq: json['deliverySeq'] as int? ?? 0,
      productCode: json['productCode'] as String? ?? '',
      processCode: json['processCode'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      qty: json['qty'] as int? ?? 0,
      discount: json['discount'] as int? ?? 0,
      cost: json['cost'] as int? ?? 0,
      orderNo: json['orderNo'] as String? ?? '',
      orderSeq: json['orderSeq'] as int? ?? 0,
      remark: json['remark'] as String?,
    );
  }
}
