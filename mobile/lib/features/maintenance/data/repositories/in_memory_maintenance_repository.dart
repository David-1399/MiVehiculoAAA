import '../../domain/entities/maintenance_record.dart';
import '../../domain/repositories/maintenance_repository.dart';

class InMemoryMaintenanceRepository implements MaintenanceRepository {
  final List<MaintenanceRecord> _items = [];

  @override
  List<MaintenanceRecord> getAll() {
    return List.unmodifiable(_items);
  }

  @override
  List<MaintenanceRecord> getByVehicleId(String vehicleId) {
    return List.unmodifiable(
      _items.where((item) => item.vehicleId == vehicleId).toList(),
    );
  }

  @override
  MaintenanceRecord? getById(String id) {
    for (final item in _items) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }

  @override
  MaintenanceRecord create(MaintenanceRecord maintenance) {
    _items.add(maintenance);

    return maintenance;
  }

  @override
  MaintenanceRecord update(MaintenanceRecord maintenance) {
    final index = _items.indexWhere((item) => item.id == maintenance.id);

    if (index == -1) {
      throw StateError('Mantenimiento no encontrado.');
    }

    _items[index] = maintenance;

    return maintenance;
  }

  @override
  void delete(String id) {
    _items.removeWhere((item) => item.id == id);
  }
}
