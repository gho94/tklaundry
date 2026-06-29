import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/code_api.dart';
import '../domain/code.dart';

class CodeListNotifier extends AsyncNotifier<List<Code>> {
  late final CodeApi _codeApi;

  @override
  Future<List<Code>> build() async {
    _codeApi = CodeApi();
    return [];
  }

  Future<void> search() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_codeApi.listCodes);
  }
}

final codeProvider =
    AsyncNotifierProvider<CodeListNotifier, List<Code>>(CodeListNotifier.new);
