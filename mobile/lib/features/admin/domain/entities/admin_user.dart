import '../../../auth/domain/entities/user_role.dart';

class AdminUser {
  const AdminUser({
    required this.id,
    required this.roleId,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.isActive,
    required this.createdAt,
    this.phone,
    this.updatedAt,
  });

  final String id;
  final String roleId;
  final UserRole role;
  final String firstName;
  final String lastName;
  final String? phone;
  final String email;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  String get fullName {
    return '$firstName $lastName'.trim();
  }
}
