import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

class ApiExpenseRepository implements ExpenseRepository {
  ApiExpenseRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<List<Expense>> getByVehicleId(String vehicleId) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/api/vehiculos/$vehicleId/gastos',
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
  Future<Expense> create(Expense expense) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/vehiculos/${expense.vehicleId}/gastos',
        data: _toJson(expense),
      );

      return _fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<Expense> update(Expense expense) async {
    try {
      final response = await _apiClient.dio.put<Map<String, dynamic>>(
        '/api/gastos/${expense.id}',
        data: _toJson(expense),
      );

      return _fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _apiClient.dio.delete<void>('/api/gastos/$id');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Map<String, dynamic> _toJson(Expense item) {
    return {
      'categoriaGastoId': item.expenseCategoryId,
      'descripcion': item.description,
      'valor': item.amount,
      'fecha': _date(item.date),
      'rutaSoporte': item.evidencePath,
      'observaciones': null,
    };
  }

  Expense _fromJson(Map<String, dynamic> json) {
    final createdAt =
        DateTime.tryParse(json['fechaCreacion']?.toString() ?? '') ??
        DateTime.now();

    return Expense(
      id: json['id']?.toString() ?? '',
      vehicleId: json['vehiculoId']?.toString() ?? '',
      expenseCategoryId: json['categoriaGastoId']?.toString() ?? '',
      description: json['descripcion']?.toString() ?? '',
      amount: (json['valor'] as num?)?.round() ?? 0,
      date: _parseDate(json['fecha']),
      evidencePath: _nullable(json['rutaSoporte']),
      createdAt: createdAt,
      updatedAt: createdAt,
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
