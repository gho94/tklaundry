class Expend {
  const Expend({
    required this.idx,
    required this.expendDate,
    required this.expendCode,
    required this.cost,
    required this.remark,
  });

  final int idx;
  final String expendDate;
  final String expendCode;
  final int cost;
  final String remark;

  factory Expend.fromJson(Map<String, dynamic> json) {
    return Expend(
      idx: json['idx'] as int? ?? 0,
      expendDate: json['expendDate'] as String? ?? '',
      expendCode: json['expendCode'] as String? ?? '',
      cost: json['cost'] as int? ?? 0,
      remark: json['remark'] as String? ?? '',
    );
  }
}
