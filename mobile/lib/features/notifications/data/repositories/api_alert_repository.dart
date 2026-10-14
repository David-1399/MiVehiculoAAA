import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/app_alert.dart';
import '../../domain/repositories/alert_repository.dart';

class ApiAlertRepository implements AlertRepository {
  ApiAlertRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<List<AppAlert>> getAll() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/api/alertas');

      return (response.data ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<int> generate() async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/alertas/generar',
      );

      return (response.data?['alertasCreadas'] as num?)?.toInt() ?? 0;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.dio.put<void>('/api/alertas/$id/leida');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  AppAlert _fromJson(Map<String, dynamic> json) {
    final type = json['tipo']?.toString().trim().toUpperCase() ?? '';
    final description = json['mensaje']?.toString() ?? '';
    final sourceType = type == 'DOCUMENTO'
        ? AlertSourceType.documentExpiration
        : AlertSourceType.maintenanceDate;

    return AppAlert(
      id: json['id']?.toString() ?? '',
      vehicleId: json['vehiculoId']?.toString() ?? '',
      vehicleLabel: '',
      title: json['titulo']?.toString() ?? 'Alerta',
      description: _cleanMessage(description),
      level: _levelFromMessage(description),
      sourceType: sourceType,
      isRead: json['leida'] == true,
      createdAt:
          DateTime.tryParse(json['fechaAlerta']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  AlertLevel _levelFromMessage(String message) {
    final normalized = message.toLowerCase();

    if (normalized.contains('vence el') ||
        normalized.contains('kilometraje') ||
        normalized.contains('fecha')) {
      return AlertLevel.warning;
    }

    return AlertLevel.info;
  }

  String _cleanMessage(String message) {
    return message
        .replaceAll(RegExp(r'\s*\[(DOC|MANT):[^\]]+\]\s*$'), '')
        .trim();
  }
}
