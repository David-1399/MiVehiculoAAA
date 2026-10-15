import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/api_auth_repository.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';

import '../../../vehicles/presentation/controllers/vehicles_provider.dart';
import '../../../mileage/presentation/controllers/mileage_provider.dart';
import '../../../maintenance/presentation/controllers/maintenance_provider.dart';
import '../../../maintenance/presentation/controllers/upcoming_maintenance_provider.dart';
import '../../../documents/presentation/controllers/documents_provider.dart';
import '../../../expenses/presentation/controllers/expenses_provider.dart';
import '../../../notifications/presentation/controllers/alerts_provider.dart';

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

    if (result.hasValue && result.value != null) {
      // SESSION_SCOPE_RESET_SIGNIN
      // Primero publicamos la nueva sesión y luego invalidamos los
      // providers dependientes. Así, al reconstruirse, leen al usuario
      // recién autenticado y cargan sus datos desde la API.
      _clearSessionScopedState();
    }

    return result.hasValue && result.value != null;
  }

  void _clearSessionScopedState() {
    ref.invalidate(vehiclesProvider);
    ref.invalidate(mileageProvider);
    ref.invalidate(maintenanceProvider);
    ref.invalidate(upcomingMaintenanceProvider);
    ref.invalidate(documentsProvider);
    ref.invalidate(expensesProvider);
    ref.invalidate(alertsProvider);
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

    // SESSION_SCOPE_RESET_SIGNOUT
    // Primero publicamos que ya no existe sesión y después invalidamos
    // cualquier estado asociado al usuario anterior.
    _clearSessionScopedState();
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, UserSession?>(
  AuthNotifier.new,
);
