import 'package:flutter_test/flutter_test.dart';
import 'package:mivehiculoaaa/app/app.dart';

void main() {
  testWidgets('La aplicacion inicia en Splash y navega al Login', (
    tester,
  ) async {
    await tester.pumpWidget(const MiVehiculoAAAApp());

    // Verifica la pantalla Splash.
    expect(find.text('MiVehiculoAAA'), findsOneWidget);

    expect(find.text('Control y mantenimiento de tu vehículo'), findsOneWidget);

    // Completa el temporizador de 2 segundos del Splash.
    await tester.pump(const Duration(seconds: 2));

    // Permite que GoRouter termine la navegación.
    await tester.pumpAndSettle();

    // Verifica que llegamos correctamente al Login.
    expect(find.text('Bienvenido'), findsOneWidget);

    expect(find.text('Iniciar sesión'), findsOneWidget);

    expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
  });
}
