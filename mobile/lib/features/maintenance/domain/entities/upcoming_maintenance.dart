class UpcomingMaintenance {
  const UpcomingMaintenance({
    required this.maintenanceId,
    required this.vehicleId,
    required this.vehicle,
    required this.plate,
    required this.maintenanceType,
    required this.currentMileage,
    this.nextDate,
    this.nextMileage,
    this.remainingKm,
    this.remainingDays,
  });

  final String maintenanceId;
  final String vehicleId;
  final String vehicle;
  final String plate;
  final String maintenanceType;
  final DateTime? nextDate;
  final int? nextMileage;
  final int currentMileage;
  final int? remainingKm;
  final int? remainingDays;
}
