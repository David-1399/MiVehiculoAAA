import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';

class InMemoryVehicleRepository implements VehicleRepository {
  final List<Vehicle> _items = [];

  @override
  List<Vehicle> getAll() {
    return List.unmodifiable(_items);
  }

  @override
  Vehicle add(Vehicle vehicle) {
    _items.add(vehicle);
    return vehicle;
  }

  @override
  Vehicle update(Vehicle vehicle) {
    final index = _items.indexWhere((item) => item.id == vehicle.id);

    if (index < 0) {
      throw StateError('El vehículo que intentas actualizar no existe.');
    }

    _items[index] = vehicle;
    return vehicle;
  }

  @override
  Vehicle? findById(String id) {
    for (final vehicle in _items) {
      if (vehicle.id == id) {
        return vehicle;
      }
    }

    return null;
  }
}
