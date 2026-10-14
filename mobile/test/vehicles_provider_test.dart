import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mivehiculoaaa/features/vehicles/domain/entities/vehicle.dart';
import 'package:mivehiculoaaa/features/vehicles/domain/repositories/vehicle_repository.dart';
import 'package:mivehiculoaaa/features/vehicles/presentation/controllers/vehicles_provider.dart';

class FakeVehicleRepository implements VehicleRepository {
  final List<Vehicle> _items = [];

  @override
  Future<List<Vehicle>> getAll() async => List.unmodifiable(_items);

  @override
  Future<Vehicle> add(Vehicle vehicle) async {
    final saved = vehicle.copyWith(id: 'veh-${_items.length + 1}');

    _items.add(saved);
    return saved;
  }

  @override
  Future<Vehicle> update(Vehicle vehicle) async {
    final index = _items.indexWhere((item) => item.id == vehicle.id);

    if (index < 0) {
      throw StateError('No existe.');
    }

    _items[index] = vehicle;
    return vehicle;
  }

  @override
  Future<Vehicle?> findById(String id) async {
    for (final item in _items) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }

  @override
  Future<void> deleteById(String id) async {
    _items.removeWhere((item) => item.id == id);
  }
}

void main() {
  test('eliminar vehiculo lo retira del estado y ajusta seleccion', () async {
    final repository = FakeVehicleRepository();

    final container = ProviderContainer(
      overrides: [vehicleRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(container.dispose);

    final notifier = container.read(vehiclesProvider.notifier);

    final first = await notifier.addVehicle(
      vehicleTypeId: 'car',
      brand: 'Marca A',
      model: 'Modelo A',
      year: 2024,
      plate: 'AAA111',
      mileage: 10000,
    );

    final second = await notifier.addVehicle(
      vehicleTypeId: 'car',
      brand: 'Marca B',
      model: 'Modelo B',
      year: 2025,
      plate: 'BBB222',
      mileage: 20000,
    );

    notifier.selectVehicle(second.id);

    await notifier.deleteVehicle(second.id);

    final state = container.read(vehiclesProvider);

    expect(state.vehicles.length, 1);
    expect(state.vehicles.single.id, first.id);
    expect(state.selectedVehicleId, first.id);
  });

  test('eliminar el ultimo vehiculo deja seleccion nula', () async {
    final repository = FakeVehicleRepository();

    final container = ProviderContainer(
      overrides: [vehicleRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(container.dispose);

    final notifier = container.read(vehiclesProvider.notifier);

    final vehicle = await notifier.addVehicle(
      vehicleTypeId: 'car',
      brand: 'Marca',
      model: 'Modelo',
      year: 2024,
      plate: 'CCC333',
      mileage: 5000,
    );

    await notifier.deleteVehicle(vehicle.id);

    final state = container.read(vehiclesProvider);

    expect(state.vehicles, isEmpty);
    expect(state.selectedVehicleId, isNull);
    expect(state.selectedVehicle, isNull);
  });
}
