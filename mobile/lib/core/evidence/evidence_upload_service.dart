import 'package:dio/dio.dart';

import '../network/api_client.dart';
import '../network/api_exception.dart';

class EvidenceUploadService {
  EvidenceUploadService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<String> uploadImage(String filePath) async {
    try {
      final fileName = filePath.split(RegExp(r'[/\\]')).last;

      final formData = FormData.fromMap({
        'archivo': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/evidencias',
        data: formData,
      );

      final path = response.data?['ruta']?.toString();

      if (path == null || path.isEmpty) {
        throw const ApiException(
          'El servidor no devolvió la ruta de la evidencia.',
        );
      }

      return path;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
