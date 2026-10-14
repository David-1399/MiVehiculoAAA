import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/local_session_auth_repository.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return LocalSessionAuthRepository();
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

    final result = await AsyncValue.guard(() async {
      return _repository.signIn(email: email, password: password);
    });

    state = result;

    return result.hasValue && result.value != null;
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
