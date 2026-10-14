import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mivehiculoaaa/features/vehicles/presentation/controllers/vehicles_provider.dart';

void main() {
  test('eliminar vehiculo lo retira del estado y ajusta seleccion', () {
    final container = ProviderContainer();

    addTearDown(container.dispose);

    final notifier = container.read(vehiclesProvider.notifier);

    final first = notifier.addVehicle(
      vehicleTypeId: 'car',
      brand: 'Marca A',
      model: 'Modelo A',
      year: 2024,
      plate: 'AAA111',
      mileage: 10000,
    );

    final second = notifier.addVehicle(
      vehicleTypeId: 'car',
      brand: 'Marca B',
      model: 'Modelo B',
      year: 2025,
      plate: 'BBB222',
      mileage: 20000,
    );

    notifier.selectVehicle(second.id);

    notifier.deleteVehicle(second.id);

    final state = container.read(vehiclesProvider);

    expect(state.vehicles.length, 1);

    expect(state.vehicles.single.id, first.id);

    expect(state.selectedVehicleId, first.id);
  });

  test('eliminar el ultimo vehiculo deja seleccion nula', () {
    final container = ProviderContainer();

    addTearDown(container.dispose);

    final notifier = container.read(vehiclesProvider.notifier);

    final vehicle = notifier.addVehicle(
      vehicleTypeId: 'car',
      brand: 'Marca',
      model: 'Modelo',
      year: 2024,
      plate: 'CCC333',
      mileage: 5000,
    );

    notifier.deleteVehicle(vehicle.id);

    final state = container.read(vehiclesProvider);

    expect(state.vehicles, isEmpty);

    expect(state.selectedVehicleId, isNull);

    expect(state.selectedVehicle, isNull);
  });
}
