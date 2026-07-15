import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/code_api.dart';
import '../domain/code.dart';

/// 로그인 응답으로 채우는 세션 캐시. 코드 화면 [search]로만 서버 갱신.
class CodeListNotifier extends Notifier<List<Code>> {
  late final CodeApi _codeApi;

  @override
  List<Code> build() {
    _codeApi = CodeApi();
    return const [];
  }

  void setCodes(List<Code> codes) {
    state = codes;
  }

  void clear() {
    state = const [];
  }

  /// 갱신 성공 시 state 교체. 실패 시 기존 캐시 유지하고 예외 전파.
  Future<void> search() async {
    state = await _codeApi.listCodes();
  }
}

final codeProvider =
    NotifierProvider<CodeListNotifier, List<Code>>(CodeListNotifier.new);
