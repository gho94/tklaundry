import 'package:intl/intl.dart';

final _integerFormat = NumberFormat('#,###', 'ko');
final _displayDateTimeFormat = DateFormat('yyyy-MM-dd a h:mm', 'ko');
final _apiDateFormat = DateFormat('yyyy-MM-dd');

extension TkNumFormat on num {
  /// 천 단위 콤마 (예: 288996000 → 288,996,000)
  String get formatted => _integerFormat.format(this);
}

extension TkDateTimeFormat on DateTime {
  /// 12시간 · 오전/오후 (예: `2026-04-24 오후 8:38`)
  String toDisplayDateTime() => _displayDateTimeFormat.format(this);

  /// API 쿼리·필터용 `yyyy-MM-dd`
  String toApiDate() => _apiDateFormat.format(this);
}

extension TkIsoDateTimeFormat on String? {
  /// ISO 일시 문자열 → 화면 표시
  ///
  /// [hideUnassigned] true면 미할당 일시(1900 이하, 출고 전 등)는 빈 문자열.
  String toDisplayDateTime({bool hideUnassigned = false}) {
    if (this == null || this!.isEmpty) return '';
    final dateTime = DateTime.tryParse(this!);
    if (dateTime == null) return this!;
    if (hideUnassigned && dateTime.year <= 1900) return '';
    return dateTime.toDisplayDateTime();
  }
}
