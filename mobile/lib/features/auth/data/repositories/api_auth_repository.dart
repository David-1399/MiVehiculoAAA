import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<UserSession?> restoreSession() async {
    final token = await _apiClient.tokenStorage.readToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/auth/perfil',
      );

      return _sessionFromProfile(response.data ?? const {}, token);
    } on DioException {
      await _apiClient.tokenStorage.clearToken();
      return null;
    }
  }

  @override
  Future<UserSession> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/auth/login',
        data: {'correo': email.trim().toLowerCase(), 'password': password},
      );

      final data = response.data ?? const {};
      final token = data['token']?.toString();

      if (token == null || token.isEmpty) {
        throw const ApiException('El servidor no devolvió un token de sesión.');
      }

      await _apiClient.tokenStorage.writeToken(token);

      final rawUser = data['usuario'];

      if (rawUser is! Map<String, dynamic>) {
        throw const ApiException(
          'La respuesta de inicio de sesión no contiene el usuario.',
        );
      }

      return _sessionFromUser(rawUser, token);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<void> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      await _apiClient.dio.post<void>(
        '/api/auth/registro',
        data: {
          'nombres': firstName.trim(),
          'apellidos': lastName.trim(),
          'telefono': phone.trim(),
          'correo': email.trim().toLowerCase(),
          'password': password,
        },
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final token = await _apiClient.tokenStorage.readToken();

      if (token != null && token.isNotEmpty) {
        await _apiClient.dio.post<void>('/api/auth/logout');
      }
    } catch (_) {
      // El logout local debe completarse incluso si la API no responde.
    } finally {
      await _apiClient.tokenStorage.clearToken();
    }
  }

  UserSession _sessionFromProfile(Map<String, dynamic> data, String token) {
    final firstName = data['nombres']?.toString().trim() ?? '';
    final lastName = data['apellidos']?.toString().trim() ?? '';

    return UserSession(
      userId: data['id']?.toString() ?? '',
      email: data['correo']?.toString() ?? '',
      displayName: '$firstName $lastName'.trim(),
      role: UserRoleX.fromCode(data['rol']?.toString()),
      accessToken: token,
    );
  }

  UserSession _sessionFromUser(Map<String, dynamic> data, String token) {
    final firstName = data['nombres']?.toString().trim() ?? '';
    final lastName = data['apellidos']?.toString().trim() ?? '';

    return UserSession(
      userId: data['id']?.toString() ?? '',
      email: data['correo']?.toString() ?? '',
      displayName: '$firstName $lastName'.trim(),
      role: UserRoleX.fromCode(data['rol']?.toString()),
      accessToken: token,
    );
  }
}
