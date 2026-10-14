import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDio(DioException error) {
    final data = error.response?.data;

    String message = 'No fue posible completar la solicitud.';

    if (data is Map<String, dynamic>) {
      final value = data['mensaje'] ?? data['message'] ?? data['title'];

      if (value != null && value.toString().trim().isNotEmpty) {
        message = value.toString();
      }
    } else if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      message = 'No fue posible conectar con el servidor. Verifica que la API esté ejecutándose.';
    }

    return ApiException(message, statusCode: error.response?.statusCode);
  }

  @override
  String toString() => message;
}
