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

  Future<Product> registerProduct({
    required String processCode,
    required String groupCode,
    required String productName,
    required int price,
  }) async {
    final body = await _client.post(
      '/products',
      body: {
        'processCode': processCode,
        'groupCode': groupCode,
        'productName': productName,
        'price': price,
      },
      fallbackMessage: '제품 등록에 실패했습니다.',
    );

    return Product.fromJson(body);
  }

  Future<void> updateProduct({
    required String productCode,
    required String productName,
    required int price,
  }) async {
    await _client.put(
      '/products/${Uri.encodeComponent(productCode)}',
      body: {
        'productName': productName,
        'price': price,
      },
      fallbackMessage: '제품 수정에 실패했습니다.',
    );
  }

  Future<void> deleteProduct(String productCode) async {
    await _client.delete(
      '/products/${Uri.encodeComponent(productCode)}',
      fallbackMessage: '제품 삭제에 실패했습니다.',
    );
  }
}
