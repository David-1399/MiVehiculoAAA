import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/repositories/admin_user_repository.dart';

class ApiAdminUserRepository implements AdminUserRepository {
  ApiAdminUserRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<List<AdminUser>> getAll() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/api/admin/usuarios',
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
  Future<AdminUser?> getById(String id) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/admin/usuarios/$id',
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
  Future<AdminUser> create({
    required String firstName,
    required String lastName,
    required String? phone,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/admin/usuarios',
        data: {
          'nombres': firstName.trim(),
          'apellidos': lastName.trim(),
          'telefono': _nullable(phone),
          'correo': email.trim().toLowerCase(),
          'password': password,
          'rol': role,
        },
      );

      return _fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<AdminUser> update({
    required String id,
    required String firstName,
    required String lastName,
    required String? phone,
    required String email,
    required String role,
    String? password,
  }) async {
    try {
      final response = await _apiClient.dio.put<Map<String, dynamic>>(
        '/api/admin/usuarios/$id',
        data: {
          'nombres': firstName.trim(),
          'apellidos': lastName.trim(),
          'telefono': _nullable(phone),
          'correo': email.trim().toLowerCase(),
          'rol': role,
          'password': _nullable(password),
        },
      );

      return _fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<void> deactivate(String id) async {
    try {
      await _apiClient.dio.delete<void>('/api/admin/usuarios/$id');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  AdminUser _fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id']?.toString() ?? '',
      roleId: json['rolId']?.toString() ?? '',
      role: UserRoleX.fromCode(json['rol']?.toString()),
      firstName: json['nombres']?.toString() ?? '',
      lastName: json['apellidos']?.toString() ?? '',
      phone: _nullable(json['telefono']?.toString()),
      email: json['correo']?.toString() ?? '',
      isActive: json['activo'] == true,
      createdAt:
          DateTime.tryParse(json['fechaCreacion']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(
        json['fechaActualizacion']?.toString() ?? '',
      ),
    );
  }

  String? _nullable(String? value) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }
}
