import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/product_api.dart';
import '../domain/product.dart';

class ProductListNotifier extends AutoDisposeAsyncNotifier<List<Product>> {
  late final ProductApi _productApi;
  String? _processCode;
  String? _groupCode;

  @override
  Future<List<Product>> build() async {
    _productApi = ProductApi();
    return [];
  }

  String? get processCode => _processCode;
  String? get groupCode => _groupCode;

  Future<void> search({
    required String processCode,
    required String groupCode,
  }) async {
    _processCode = processCode;
    _groupCode = groupCode;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _productApi.listProducts(
        processCode: processCode,
        groupCode: groupCode,
      ),
    );
  }
}

final productListProvider =
    AsyncNotifierProvider.autoDispose<ProductListNotifier, List<Product>>(
  ProductListNotifier.new,
);
