import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/user_role.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';

class LocalSessionAuthRepository implements AuthRepository {
  LocalSessionAuthRepository({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _userIdKey = 'auth_user_id';
  static const _emailKey = 'auth_email';
  static const _displayNameKey = 'auth_display_name';
  static const _roleKey = 'auth_role';

  final FlutterSecureStorage _storage;

  @override
  Future<UserSession?> restoreSession() async {
    try {
      final email = await _storage.read(key: _emailKey);

      final userId = await _storage.read(key: _userIdKey);

      if (email == null ||
          email.trim().isEmpty ||
          userId == null ||
          userId.trim().isEmpty) {
        return null;
      }

      final displayName = await _storage.read(key: _displayNameKey);

      final roleCode = await _storage.read(key: _roleKey);

      return UserSession(
        userId: userId,
        email: email,
        displayName: displayName?.trim().isEmpty == true ? null : displayName,
        role: UserRoleX.fromCode(roleCode),
      );
    } catch (_) {
      // Permite que pruebas/widget tests funcionen
      // incluso cuando el plugin nativo no esta disponible.
      return null;
    }
  }

  @override
  Future<UserSession> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw ArgumentError('El correo es obligatorio.');
    }

    if (password.isEmpty) {
      throw ArgumentError('La contraseña es obligatoria.');
    }

    // Este adaptador NO valida credenciales.
    // Solo conserva la sesion ingresada para el prototipo movil.
    // La validacion real sera responsabilidad de ApiAuthRepository.
    final session = UserSession(
      userId: 'local:$normalizedEmail',
      email: normalizedEmail,
      role: UserRole.owner,
    );

    try {
      await _storage.write(key: _userIdKey, value: session.userId);

      await _storage.write(key: _emailKey, value: session.email);

      await _storage.write(key: _roleKey, value: session.role.code);

      await _storage.delete(key: _displayNameKey);
    } catch (_) {
      // En ejecucion normal Android/iOS el plugin esta disponible.
      // El estado en memoria sigue siendo valido si el almacenamiento
      // no esta disponible durante una prueba automatizada.
    }

    return session;
  }

  @override
  Future<void> signOut() async {
    try {
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _emailKey);
      await _storage.delete(key: _displayNameKey);
      await _storage.delete(key: _roleKey);
    } catch (_) {
      // Sin datos de sesion sensibles en memoria persistente.
    }
  }
}
