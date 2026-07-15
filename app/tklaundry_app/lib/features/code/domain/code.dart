class Code {
  const Code({
    required this.codeId,
    required this.pCodeId,
    required this.codeName,
  });

  final String codeId;
  final String pCodeId;
  final String codeName;

  factory Code.fromJson(Map<String, dynamic> json) {
    return Code(
      codeId: (json['codeId'] as String).trim(),
      pCodeId: (json['pCodeId'] as String? ?? '').trim(),
      codeName: (json['codeName'] as String? ?? '').trim(),
    );
  }

  /// DB `PCodeID`는 `"Root  "` 등 공백·대소문자가 섞일 수 있다.
  static bool isRootParent(String? pCodeId) {
    return pCodeId?.trim().toUpperCase() == 'ROOT';
  }

  String get parentLabel {
    return isRootParent(pCodeId) ? 'Root' : pCodeId.trim();
  }
}
