import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/expend_api.dart';
import '../domain/expend_list_result.dart';

class ExpendSearchParams {
  const ExpendSearchParams({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;
}

class ExpendListNotifier extends AutoDisposeAsyncNotifier<ExpendListResult> {
  late final ExpendApi _expendApi;

  @override
  Future<ExpendListResult> build() async {
    _expendApi = ExpendApi();
    return ExpendListResult.empty;
  }

  Future<void> search(ExpendSearchParams params) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _expendApi.listExpends(
        startDate: params.startDate,
        endDate: params.endDate,
      ),
    );
  }
}

final expendListProvider = AsyncNotifierProvider.autoDispose<
    ExpendListNotifier, ExpendListResult>(
  ExpendListNotifier.new,
);
