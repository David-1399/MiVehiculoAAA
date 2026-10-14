class MaintenanceRecord {
  const MaintenanceRecord({
    required this.id,
    required this.vehicleId,
    required this.maintenanceTypeId,
    required this.date,
    required this.mileage,
    required this.cost,
    required this.createdAt,
    required this.updatedAt,
    this.workshop,
    this.observations,
    this.nextMileage,
    this.nextDate,
    this.evidencePath,
  });

  final String id;
  final String vehicleId;
  final String maintenanceTypeId;

  final DateTime date;
  final int mileage;
  final int cost;

  final String? workshop;
  final String? observations;

  final int? nextMileage;
  final DateTime? nextDate;

  final String? evidencePath;

  final DateTime createdAt;
  final DateTime updatedAt;

  MaintenanceRecord copyWith({
    String? id,
    String? vehicleId,
    String? maintenanceTypeId,
    DateTime? date,
    int? mileage,
    int? cost,
    String? workshop,
    String? observations,
    int? nextMileage,
    DateTime? nextDate,
    String? evidencePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaintenanceRecord(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      maintenanceTypeId: maintenanceTypeId ?? this.maintenanceTypeId,
      date: date ?? this.date,
      mileage: mileage ?? this.mileage,
      cost: cost ?? this.cost,
      workshop: workshop ?? this.workshop,
      observations: observations ?? this.observations,
      nextMileage: nextMileage ?? this.nextMileage,
      nextDate: nextDate ?? this.nextDate,
      evidencePath: evidencePath ?? this.evidencePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
