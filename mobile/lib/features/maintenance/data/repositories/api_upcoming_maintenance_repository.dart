import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/upcoming_maintenance.dart';
import '../../domain/repositories/upcoming_maintenance_repository.dart';

class ApiUpcomingMaintenanceRepository
    implements UpcomingMaintenanceRepository {
  ApiUpcomingMaintenanceRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<List<UpcomingMaintenance>> getUpcoming({
    int days = 30,
    int kilometers = 1000,
  }) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/api/mantenimientos/proximos',
        queryParameters: {'dias': days, 'kilometros': kilometers},
      );

      return (response.data ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  UpcomingMaintenance _fromJson(Map<String, dynamic> json) {
    return UpcomingMaintenance(
      maintenanceId: json['mantenimientoId']?.toString() ?? '',
      vehicleId: json['vehiculoId']?.toString() ?? '',
      vehicle: json['vehiculo']?.toString() ?? '',
      plate: json['placa']?.toString() ?? '',
      maintenanceType: json['tipoMantenimiento']?.toString() ?? 'Mantenimiento',
      nextDate: json['proximaFecha'] == null
          ? null
          : DateTime.tryParse(json['proximaFecha'].toString()),
      nextMileage: (json['proximoKilometraje'] as num?)?.toInt(),
      currentMileage: (json['kilometrajeActual'] as num?)?.toInt() ?? 0,
      remainingKm: (json['kilometrosRestantes'] as num?)?.toInt(),
      remainingDays: (json['diasRestantes'] as num?)?.toInt(),
    );
  }
}
