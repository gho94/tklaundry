class ApiException implements Exception {
  ApiException({
    required this.message,
    this.traceId,
    this.code,
    this.statusCode,
  });

  final String message;
  final String? traceId;
  final String? code;
  final int? statusCode;
}
