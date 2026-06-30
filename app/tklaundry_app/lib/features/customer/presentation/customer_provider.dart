import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/customer_api.dart';
import '../domain/customer.dart';

class CustomerListNotifier extends AutoDisposeAsyncNotifier<List<Customer>> {
  late final CustomerApi _customerApi;
  String? _aptCode;

  @override
  Future<List<Customer>> build() async {
    _customerApi = CustomerApi();
    return [];
  }

  String? get aptCode => _aptCode;

  Future<void> search(String? aptCode) async {
    _aptCode = aptCode;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _customerApi.listCustomers(aptCode: aptCode),
    );
  }
}

final customerListProvider =
    AsyncNotifierProvider.autoDispose<CustomerListNotifier, List<Customer>>(
  CustomerListNotifier.new,
);
