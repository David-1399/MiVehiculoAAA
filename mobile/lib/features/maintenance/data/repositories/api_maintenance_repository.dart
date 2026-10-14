import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/maintenance_record.dart';
import '../../domain/repositories/maintenance_repository.dart';

class ApiMaintenanceRepository implements MaintenanceRepository {
  ApiMaintenanceRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<List<MaintenanceRecord>> getByVehicleId(String vehicleId) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/api/vehiculos/$vehicleId/mantenimientos',
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
  Future<MaintenanceRecord?> getById(String id) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/mantenimientos/$id',
      );

      return _fromJson(response.data ?? const {});
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }

      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<MaintenanceRecord> create(MaintenanceRecord maintenance) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/vehiculos/${maintenance.vehicleId}/mantenimientos',
        data: _toJson(maintenance),
      );

      return _fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<MaintenanceRecord> update(MaintenanceRecord maintenance) async {
    try {
      final response = await _apiClient.dio.put<Map<String, dynamic>>(
        '/api/mantenimientos/${maintenance.id}',
        data: _toJson(maintenance),
      );

      return _fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _apiClient.dio.delete<void>('/api/mantenimientos/$id');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Map<String, dynamic> _toJson(MaintenanceRecord item) {
    return {
      'tipoMantenimientoId': item.maintenanceTypeId,
      'descripcion': item.observations?.trim().isNotEmpty == true
          ? item.observations!.trim()
          : 'Mantenimiento',
      'fecha': _date(item.date),
      'kilometraje': item.mileage,
      'costo': item.cost,
      'taller': item.workshop,
      'proximoKilometraje': item.nextMileage,
      'proximaFecha': item.nextDate == null ? null : _date(item.nextDate!),
      'observaciones': item.observations,
    };
  }

  MaintenanceRecord _fromJson(Map<String, dynamic> json) {
    final createdAt =
        DateTime.tryParse(json['fechaCreacion']?.toString() ?? '') ??
        DateTime.now();

    return MaintenanceRecord(
      id: json['id']?.toString() ?? '',
      vehicleId: json['vehiculoId']?.toString() ?? '',
      maintenanceTypeId: json['tipoMantenimientoId']?.toString() ?? '',
      date: _parseDate(json['fecha']),
      mileage: (json['kilometraje'] as num?)?.toInt() ?? 0,
      cost: (json['costo'] as num?)?.round() ?? 0,
      workshop: _nullable(json['taller']),
      observations:
          _nullable(json['observaciones']) ?? _nullable(json['descripcion']),
      nextMileage: (json['proximoKilometraje'] as num?)?.toInt(),
      nextDate: json['proximaFecha'] == null
          ? null
          : _parseDate(json['proximaFecha']),
      createdAt: createdAt,
      updatedAt:
          DateTime.tryParse(json['fechaActualizacion']?.toString() ?? '') ??
          createdAt,
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

  String? _nullable(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
