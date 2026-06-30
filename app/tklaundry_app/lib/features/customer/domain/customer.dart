class Customer {
  const Customer({
    required this.custCode,
    required this.custName,
    required this.aptCode,
    required this.buildingCode,
    required this.floorCode,
    required this.roomCode,
    required this.custPhone,
  });

  final String custCode;
  final String custName;
  final String aptCode;
  final String buildingCode;
  final String floorCode;
  final String roomCode;
  final String custPhone;

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      custCode: json['custCode'] as String? ?? '',
      custName: json['custName'] as String? ?? '',
      aptCode: json['aptCode'] as String? ?? '',
      buildingCode: json['buildingCode'] as String? ?? '',
      floorCode: json['floorCode'] as String? ?? '',
      roomCode: json['roomCode'] as String? ?? '',
      custPhone: json['custPhone'] as String? ?? '',
    );
  }
}
