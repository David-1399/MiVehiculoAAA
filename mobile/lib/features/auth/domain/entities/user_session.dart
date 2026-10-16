import 'user_role.dart';

class UserSession {
  const UserSession({
    required this.userId,
    required this.email,
    required this.role,
    this.displayName,
    this.accessToken,
  });

  final String userId;
  final String email;
  final String? displayName;
  final UserRole role;

  final String? accessToken;

  bool get hasDisplayName {
    final value = displayName;
    return value != null && value.trim().isNotEmpty;
  }

  String get profileTitle {
    if (hasDisplayName) {
      return displayName!.trim();
    }

    return email;
  }
}
