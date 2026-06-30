import '../../../core/network/api_client.dart';
import '../domain/product.dart';

class ProductApi {
  ProductApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<Product>> listProducts({
    required String processCode,
    required String groupCode,
  }) async {
    final body = await _client.getList(
      '/products',
      queryParameters: {
        'processCode': processCode,
        'groupCode': groupCode,
      },
      fallbackMessage: '제품 목록을 불러오지 못했습니다.',
    );

    return body
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
