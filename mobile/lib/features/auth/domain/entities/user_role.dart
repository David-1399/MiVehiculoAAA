enum UserRole { owner, administrator }

extension UserRoleX on UserRole {
  String get code {
    switch (this) {
      case UserRole.owner:
        return 'OWNER';
      case UserRole.administrator:
        return 'ADMIN';
    }
  }

  String get label {
    switch (this) {
      case UserRole.owner:
        return 'Propietario';
      case UserRole.administrator:
        return 'Administrador';
    }
  }

  static UserRole fromCode(String? value) {
    switch (value?.toUpperCase()) {
      case 'ADMIN':
        return UserRole.administrator;
      case 'OWNER':
      default:
        return UserRole.owner;
    }
  }
}
