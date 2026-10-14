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
  Future<void> signOut() async {}
}

void main() {
  testWidgets(
    'La aplicacion inicia en Splash y navega al Login',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              FakeAuthRepository(),
            ),
          ],
          child: const MiVehiculoAAAApp(),
        ),
      );

      // Splash visible inicialmente.
      expect(
        find.text('MiVehiculoAAA'),
        findsOneWidget,
      );

      expect(
        find.text(
          'Control y mantenimiento de tu vehículo',
        ),
        findsOneWidget,
      );

      // Permite que restoreSession() finalice.
      await tester.pump();

      // Completa el tiempo mínimo del Splash.
      await tester.pump(
        const Duration(seconds: 2),
      );

      // Procesa la navegación de GoRouter.
      await tester.pumpAndSettle();

      // Sin sesión restaurada debe ir al Login.
      expect(
        find.text('Bienvenido'),
        findsOneWidget,
      );

      expect(
        find.text('Iniciar sesión'),
        findsOneWidget,
      );

      expect(
        find.text(
          '¿Olvidaste tu contraseña?',
        ),
        findsOneWidget,
      );
    },
  );
}