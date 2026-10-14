import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';

class ApiVehicleRepository implements VehicleRepository {
  ApiVehicleRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<List<Vehicle>> getAll() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/api/vehiculos',
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
  Future<Vehicle?> findById(String id) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/vehiculos/$id',
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
  Future<Vehicle> add(Vehicle vehicle) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/vehiculos',
        data: {
          'tipoVehiculoId': vehicle.vehicleTypeId,
          'marca': vehicle.brand,
          'modelo': vehicle.model,
          'anio': vehicle.year,
          'placa': vehicle.plate,
          'kilometraje': vehicle.mileage,
        },
      );

      return _fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<Vehicle> update(Vehicle vehicle) async {
    try {
      final response = await _apiClient.dio.put<Map<String, dynamic>>(
        '/api/vehiculos/${vehicle.id}',
        data: {
          'tipoVehiculoId': vehicle.vehicleTypeId,
          'marca': vehicle.brand,
          'modelo': vehicle.model,
          'anio': vehicle.year,
          'placa': vehicle.plate,
        },
      );

      return _fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<void> deleteById(String id) async {
    try {
      await _apiClient.dio.delete<void>('/api/vehiculos/$id');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Vehicle _fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id']?.toString() ?? '',
      vehicleTypeId: json['tipoVehiculoId']?.toString() ?? '',
      brand: json['marca']?.toString() ?? '',
      model: json['modelo']?.toString() ?? '',
      year: (json['anio'] as num?)?.toInt() ?? 0,
      plate: json['placa']?.toString() ?? '',
      mileage: (json['kilometraje'] as num?)?.toInt() ?? 0,
    );
  }
}
