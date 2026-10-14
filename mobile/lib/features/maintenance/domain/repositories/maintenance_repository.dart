import '../entities/maintenance_record.dart';

abstract interface class MaintenanceRepository {
  Future<List<MaintenanceRecord>> getByVehicleId(String vehicleId);

  Future<MaintenanceRecord?> getById(String id);

  Future<MaintenanceRecord> create(MaintenanceRecord maintenance);

  Future<MaintenanceRecord> update(MaintenanceRecord maintenance);

  Future<void> delete(String id);
}
