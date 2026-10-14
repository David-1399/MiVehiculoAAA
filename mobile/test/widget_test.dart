import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mivehiculoaaa/app/app.dart';
import 'package:mivehiculoaaa/features/auth/domain/entities/user_session.dart';
import 'package:mivehiculoaaa/features/auth/domain/repositories/auth_repository.dart';
import 'package:mivehiculoaaa/features/auth/presentation/controllers/auth_provider.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<UserSession?> restoreSession() async {
    return null;
  }

  @override
  Future<UserSession> signIn({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('La aplicacion inicia en Splash y navega al Login', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: const MiVehiculoAAAApp(),
      ),
    );

    expect(find.text('MiVehiculoAAA'), findsOneWidget);
    expect(find.text('Control y mantenimiento de tu vehículo'), findsOneWidget);

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
  });
}
