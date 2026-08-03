import '../../sales/domain/sales.dart';

class SalesChartDailyItem {
  const SalesChartDailyItem({
    required this.salesDate,
    required this.salesNo,
    required this.salesType,
    required this.custCode,
    required this.qty,
    required this.discount,
    required this.expendCode,
    required this.cost,
    required this.status,
    required this.bankingYn,
  });

  final String salesDate;
  final String salesNo;
  final String salesType;
  final String custCode;
  final int qty;
  final int discount;
  final String expendCode;
  final int cost;
  final String status;
  final String bankingYn;

  bool get isExpendRow => salesType == '지출';

  factory SalesChartDailyItem.fromJson(Map<String, dynamic> json) {
    return SalesChartDailyItem(
      salesDate: json['salesDate'] as String? ?? '',
      salesNo: json['salesNo'] as String? ?? '',
      salesType: json['salesType'] as String? ?? '',
      custCode: json['custCode'] as String? ?? '',
      qty: json['qty'] as int? ?? 0,
      discount: json['discount'] as int? ?? 0,
      expendCode: json['expendCode'] as String? ?? '',
      cost: json['cost'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      bankingYn: json['bankingYn'] as String? ?? '',
    );
  }

  Sales toSales() {
    return Sales(
      salesNo: salesNo,
      salesDate: salesDate,
      custCode: custCode,
      qty: qty,
      discount: discount,
      cost: cost,
      bankingYn: bankingYn,
      status: status,
      salesYn: 'Y',
    );
  }
}
