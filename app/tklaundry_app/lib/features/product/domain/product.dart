class Product {
  const Product({
    required this.productCode,
    required this.processCode,
    required this.groupCode,
    required this.productName,
    required this.price,
  });

  final String productCode;
  final String processCode;
  final String groupCode;
  final String productName;
  final int? price;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productCode: json['productCode'] as String? ?? '',
      processCode: json['processCode'] as String? ?? '',
      groupCode: json['groupCode'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      price: json['price'] as int?,
    );
  }
}
