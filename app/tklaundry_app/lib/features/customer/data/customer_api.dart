import '../../../core/network/api_client.dart';
import '../domain/customer.dart';

class CustomerApi {
  CustomerApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<Customer>> listCustomers({String? aptCode}) async {
    final body = await _client.getList(
      '/customers',
      queryParameters: aptCode != null ? {'aptCode': aptCode} : null,
      fallbackMessage: '고객 목록을 불러오지 못했습니다.',
    );

    return body
        .map((item) => Customer.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Customer> registerCustomer({
    required String custName,
    String? aptCode,
    String? buildingCode,
    String? floorCode,
    String? roomCode,
    String? custPhone,
  }) async {
    final body = await _client.post(
      '/customers',
      body: {
        'custName': custName,
        'aptCode': aptCode,
        'buildingCode': buildingCode,
        'floorCode': floorCode,
        'roomCode': roomCode,
        'custPhone': custPhone,
      },
      fallbackMessage: '고객 등록에 실패했습니다.',
    );

    return Customer.fromJson(body);
  }

  Future<void> updateCustomer({
    required String custCode,
    required String custName,
    String? aptCode,
    String? buildingCode,
    String? floorCode,
    String? roomCode,
    String? custPhone,
  }) async {
    await _client.put(
      '/customers/${Uri.encodeComponent(custCode)}',
      body: {
        'custName': custName,
        'aptCode': aptCode,
        'buildingCode': buildingCode,
        'floorCode': floorCode,
        'roomCode': roomCode,
        'custPhone': custPhone,
      },
      fallbackMessage: '고객 수정에 실패했습니다.',
    );
  }

  Future<void> deleteCustomer(String custCode) async {
    await _client.delete(
      '/customers/${Uri.encodeComponent(custCode)}',
      fallbackMessage: '고객 삭제에 실패했습니다.',
    );
  }
}
