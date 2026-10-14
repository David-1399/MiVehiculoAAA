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
    required this.isRead,
    required this.createdAt,
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
  final bool isRead;
  final DateTime createdAt;
  final int? distanceKm;
  final DateTime? dueDate;

  String get vehicle => vehicleLabel;

  AppAlert copyWith({bool? isRead, String? vehicleLabel}) {
    return AppAlert(
      id: id,
      vehicleId: vehicleId,
      vehicleLabel: vehicleLabel ?? this.vehicleLabel,
      title: title,
      description: description,
      level: level,
      sourceType: sourceType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      distanceKm: distanceKm,
      dueDate: dueDate,
    );
  }
}
