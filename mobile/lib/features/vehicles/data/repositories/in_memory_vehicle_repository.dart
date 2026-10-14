import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';

class InMemoryVehicleRepository implements VehicleRepository {
  final List<Vehicle> _items = [];

  @override
  Future<List<Vehicle>> getAll() async {
    return List.unmodifiable(_items);
  }

  @override
  Future<Vehicle> add(Vehicle vehicle) async {
    _items.add(vehicle);
    return vehicle;
  }

  @override
  Future<Vehicle> update(Vehicle vehicle) async {
    final index = _items.indexWhere((item) => item.id == vehicle.id);

    if (index < 0) {
      throw StateError('El vehículo que intentas actualizar no existe.');
    }

    _items[index] = vehicle;
    return vehicle;
  }

  @override
  Future<Vehicle?> findById(String id) async {
    for (final vehicle in _items) {
      if (vehicle.id == id) {
        return vehicle;
      }
    }

    return null;
  }

  @override
  Future<void> deleteById(String id) async {
    final before = _items.length;

    _items.removeWhere((vehicle) => vehicle.id == id);

    if (_items.length == before) {
      throw StateError('El vehículo que intentas eliminar no existe.');
    }
  }
}
