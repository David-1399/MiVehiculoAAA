import '../entities/upcoming_maintenance.dart';

abstract interface class UpcomingMaintenanceRepository {
  Future<List<UpcomingMaintenance>> getUpcoming({
    int days = 30,
    int kilometers = 1000,
  });
}
