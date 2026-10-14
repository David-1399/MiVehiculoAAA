import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/mileage_record.dart';
import '../../domain/repositories/mileage_repository.dart';

class ApiMileageRepository implements MileageRepository {
  ApiMileageRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<List<MileageRecord>> getByVehicleId(String vehicleId) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/api/vehiculos/$vehicleId/kilometrajes',
      );

      return (response.data ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<MileageRecord> create(MileageRecord record) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/vehiculos/${record.vehicleId}/kilometrajes',
        data: {
          'kilometraje': record.mileage,
          'fecha': _date(record.recordedAt),
          'observaciones': null,
        },
      );

      return _fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  MileageRecord _fromJson(Map<String, dynamic> json) {
    return MileageRecord(
      id: json['id']?.toString() ?? '',
      vehicleId: json['vehiculoId']?.toString() ?? '',
      mileage: (json['kilometraje'] as num?)?.toInt() ?? 0,
      recordedAt: _parseDate(json['fecha']),
      createdAt:
          DateTime.tryParse(json['fechaCreacion']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  DateTime _parseDate(Object? value) {
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }

  String _date(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');

    return '${value.year}-$month-$day';
  }
}
