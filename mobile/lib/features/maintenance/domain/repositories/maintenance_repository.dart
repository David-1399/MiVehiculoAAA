import '../entities/maintenance_record.dart';

abstract interface class MaintenanceRepository {
  List<MaintenanceRecord> getAll();

  List<MaintenanceRecord> getByVehicleId(String vehicleId);

  MaintenanceRecord? getById(String id);

  MaintenanceRecord create(MaintenanceRecord maintenance);

  MaintenanceRecord update(MaintenanceRecord maintenance);

  void delete(String id);
}
