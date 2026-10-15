import '../entities/admin_user.dart';

abstract interface class AdminUserRepository {
  Future<List<AdminUser>> getAll();

  Future<AdminUser?> getById(String id);

  Future<AdminUser> create({
    required String firstName,
    required String lastName,
    required String? phone,
    required String email,
    required String password,
    required String role,
  });

  Future<AdminUser> update({
    required String id,
    required String firstName,
    required String lastName,
    required String? phone,
    required String email,
    required String role,
    String? password,
  });

  Future<void> deactivate(String id);
}
