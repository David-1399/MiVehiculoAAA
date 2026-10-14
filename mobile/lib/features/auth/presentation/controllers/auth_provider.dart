import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/api_auth_repository.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository();
});

class AuthNotifier extends AsyncNotifier<UserSession?> {
  AuthRepository get _repository {
    return ref.read(authRepositoryProvider);
  }

  @override
  Future<UserSession?> build() {
    return _repository.restoreSession();
  }

  Future<bool> signIn({required String email, required String password}) async {
    state = const AsyncLoading<UserSession?>();

    final result = await AsyncValue.guard(
      () => _repository.signIn(email: email, password: password),
    );

    state = result;

    return result.hasValue && result.value != null;
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
  }) {
    return _repository.register(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading<UserSession?>();

    await _repository.signOut();

    state = const AsyncData<UserSession?>(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, UserSession?>(
  AuthNotifier.new,
);
