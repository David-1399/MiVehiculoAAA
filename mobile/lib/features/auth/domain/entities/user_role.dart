enum UserRole { owner, administrator }

extension UserRoleX on UserRole {
  String get code {
    switch (this) {
      case UserRole.owner:
        return 'PROPIETARIO';
      case UserRole.administrator:
        return 'ADMINISTRADOR';
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
    switch (value?.trim().toUpperCase()) {
      case 'ADMIN':
      case 'ADMINISTRADOR':
        return UserRole.administrator;
      case 'OWNER':
      case 'PROPIETARIO':
      default:
        return UserRole.owner;
    }
  }
}
