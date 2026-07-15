import '../../../shared/widgets/tk_combo_box.dart';
import '../domain/code.dart';

extension CodeListExtensions on List<Code> {
  Map<String, String> get nameById => Map.fromEntries(
        map((code) => MapEntry(code.codeId, code.codeName)),
      );

  /// 그리드·다이얼로그 표시명. 없으면 [codeId] 그대로.
  String displayName(String codeId) {
    if (codeId.isEmpty) return '';
    return _nameOrNull(codeId) ?? codeId;
  }

  String? nameOrNull(String codeId) => _nameOrNull(codeId);

  /// [parentCodeId] 직속 자식 콤보 (`codeId` 오름차순).
  List<TkComboItem<String>> comboItems(
    String parentCodeId, {
    bool includeOther = false,
    String otherLabel = '기타',
  }) {
    final parentKey = parentCodeId.trim();
    final children = where((code) => code.pCodeId == parentKey).toList()
      ..sort((a, b) => a.codeId.compareTo(b.codeId));

    return [
      for (final code in children)
        TkComboItem(value: code.codeId, label: code.codeName),
      if (includeOther) TkComboItem(value: '', label: otherLabel),
    ];
  }

  String? _nameOrNull(String codeId) {
    if (codeId.isEmpty) return null;
    final key = codeId.trim();
    for (final code in this) {
      if (code.codeId == key) return code.codeName;
    }
    return null;
  }
}
