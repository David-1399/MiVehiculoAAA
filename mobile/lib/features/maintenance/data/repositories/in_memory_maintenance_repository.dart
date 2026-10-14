import '../../domain/entities/maintenance_record.dart';
import '../../domain/repositories/maintenance_repository.dart';

class InMemoryMaintenanceRepository implements MaintenanceRepository {
  final List<MaintenanceRecord> _items = [];

  @override
  Future<List<MaintenanceRecord>> getByVehicleId(String vehicleId) async {
    return List.unmodifiable(
      _items.where((item) => item.vehicleId == vehicleId).toList(),
    );
  }

  @override
  Future<MaintenanceRecord?> getById(String id) async {
    for (final item in _items) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }

  @override
  Future<MaintenanceRecord> create(MaintenanceRecord maintenance) async {
    _items.add(maintenance);
    return maintenance;
  }

  @override
  Future<MaintenanceRecord> update(MaintenanceRecord maintenance) async {
    final index = _items.indexWhere((item) => item.id == maintenance.id);

    if (index == -1) {
      throw StateError('Mantenimiento no encontrado.');
    }

    _items[index] = maintenance;
    return maintenance;
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
  }
}
