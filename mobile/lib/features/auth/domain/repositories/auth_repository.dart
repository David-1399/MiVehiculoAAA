import '../entities/user_session.dart';

abstract interface class AuthRepository {
  Future<UserSession?> restoreSession();

  Future<UserSession> signIn({required String email, required String password});

  Future<void> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
  });

  Future<void> signOut();
}
