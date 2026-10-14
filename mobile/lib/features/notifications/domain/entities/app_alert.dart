enum AlertLevel { info, warning, critical }

enum AlertSourceType { maintenanceMileage, maintenanceDate, documentExpiration }

class AppAlert {
  const AppAlert({
    required this.id,
    required this.vehicleId,
    required this.vehicleLabel,
    required this.title,
    required this.description,
    required this.level,
    required this.sourceType,
    this.distanceKm,
    this.dueDate,
  });

  final String id;
  final String vehicleId;
  final String vehicleLabel;
  final String title;
  final String description;
  final AlertLevel level;
  final AlertSourceType sourceType;
  final int? distanceKm;
  final DateTime? dueDate;

  /// Compatibilidad con las vistas existentes.
  /// El valor no esta quemado: se deriva del vehiculo real.
  String get vehicle => vehicleLabel;
}
