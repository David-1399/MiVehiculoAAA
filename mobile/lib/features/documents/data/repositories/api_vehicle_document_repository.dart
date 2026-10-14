import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/vehicle_document.dart';
import '../../domain/repositories/vehicle_document_repository.dart';

class ApiVehicleDocumentRepository implements VehicleDocumentRepository {
  ApiVehicleDocumentRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<List<VehicleDocument>> getByVehicleId(String vehicleId) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/api/vehiculos/$vehicleId/documentos',
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
  Future<VehicleDocument> create(VehicleDocument document) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/vehiculos/${document.vehicleId}/documentos',
        data: _toJson(document),
      );

      return _fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<VehicleDocument> update(VehicleDocument document) async {
    try {
      final response = await _apiClient.dio.put<Map<String, dynamic>>(
        '/api/documentos/${document.id}',
        data: _toJson(document),
      );

      return _fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _apiClient.dio.delete<void>('/api/documentos/$id');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Map<String, dynamic> _toJson(VehicleDocument item) {
    return {
      'tipoDocumentoId': item.documentTypeId,
      'numeroReferencia': item.number,
      'entidadEmisora': null,
      'fechaExpedicion': _date(item.issueDate),
      'fechaVencimiento': item.expirationDate == null
          ? null
          : _date(item.expirationDate!),
      'rutaArchivo': item.evidencePath,
      'observaciones': null,
    };
  }

  VehicleDocument _fromJson(Map<String, dynamic> json) {
    final createdAt =
        DateTime.tryParse(json['fechaCreacion']?.toString() ?? '') ??
        DateTime.now();

    return VehicleDocument(
      id: json['id']?.toString() ?? '',
      vehicleId: json['vehiculoId']?.toString() ?? '',
      documentTypeId: json['tipoDocumentoId']?.toString() ?? '',
      number: json['numeroReferencia']?.toString() ?? '',
      issueDate: _parseDate(json['fechaExpedicion']),
      expirationDate: json['fechaVencimiento'] == null
          ? null
          : _parseDate(json['fechaVencimiento']),
      evidencePath: _nullable(json['rutaArchivo']),
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
