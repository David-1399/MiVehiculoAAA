class Expense {
  const Expense({
    required this.id,
    required this.vehicleId,
    required this.expenseCategoryId,
    required this.description,
    required this.amount,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.maintenanceId,
    this.evidencePath,
  });

  final String id;
  final String vehicleId;
  final String expenseCategoryId;

  final String description;
  final int amount;
  final DateTime date;

  final String? maintenanceId;
  final String? evidencePath;

  final DateTime createdAt;
  final DateTime updatedAt;

  Expense copyWith({
    String? id,
    String? vehicleId,
    String? expenseCategoryId,
    String? description,
    int? amount,
    DateTime? date,
    String? maintenanceId,
    bool clearMaintenanceId = false,
    String? evidencePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      expenseCategoryId: expenseCategoryId ?? this.expenseCategoryId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      maintenanceId: clearMaintenanceId
          ? null
          : maintenanceId ?? this.maintenanceId,
      evidencePath: evidencePath ?? this.evidencePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
