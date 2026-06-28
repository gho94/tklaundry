import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParameters,
    String fallbackMessage = '요청에 실패했습니다.',
  }) {
    return _request(
      'GET',
      path,
      queryParameters: queryParameters,
      fallbackMessage: fallbackMessage,
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
    String fallbackMessage = '요청에 실패했습니다.',
  }) {
    return _request(
      'POST',
      path,
      body: body,
      fallbackMessage: fallbackMessage,
    );
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Object? body,
    String fallbackMessage = '요청에 실패했습니다.',
  }) {
    return _request(
      'PUT',
      path,
      body: body,
      fallbackMessage: fallbackMessage,
    );
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    String fallbackMessage = '요청에 실패했습니다.',
  }) {
    return _request(
      'DELETE',
      path,
      fallbackMessage: fallbackMessage,
    );
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, String>? queryParameters,
    Object? body,
    required String fallbackMessage,
  }) async {
    final requestId = _newRequestId();
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.apiPrefix}$path',
    ).replace(queryParameters: queryParameters);

    http.Response response;
    try {
      response = await _send(method, uri, requestId, body);
    } catch (_) {
      throw ApiException(
        message: '서버에 연결할 수 없습니다. API가 실행 중인지 확인해 주세요.',
        traceId: requestId,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw _parseError(response, requestId, fallbackMessage);
  }

  Future<http.Response> _send(
    String method,
    Uri uri,
    String requestId,
    Object? body,
  ) {
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'X-Request-Id': requestId,
    };

    return switch (method) {
      'GET' => _client.get(uri, headers: headers),
      'POST' => _client.post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        ),
      'PUT' => _client.put(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        ),
      'DELETE' => _client.delete(uri, headers: headers),
      _ => throw ArgumentError('Unsupported method: $method'),
    };
  }

  ApiException _parseError(
    http.Response response,
    String requestId,
    String fallbackMessage,
  ) {
    var message = fallbackMessage;
    String? traceId;
    String? code;

    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message = body['message'] as String? ?? fallbackMessage;
      traceId = body['traceId'] as String?;
      code = body['code'] as String?;
    } catch (_) {}

    return ApiException(
      message: message,
      traceId: traceId ?? response.headers['x-request-id'] ?? requestId,
      code: code,
      statusCode: response.statusCode,
    );
  }

  String _newRequestId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
