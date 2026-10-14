class Vehicle {
  const Vehicle({
    required this.id,
    required this.vehicleTypeId,
    required this.brand,
    required this.model,
    required this.year,
    required this.plate,
    required this.mileage,
  });

  final String id;
  final String vehicleTypeId;
  final String brand;
  final String model;
  final int year;
  final String plate;
  final int mileage;

  String get displayName => '$brand $model';

  Vehicle copyWith({
    String? id,
    String? vehicleTypeId,
    String? brand,
    String? model,
    int? year,
    String? plate,
    int? mileage,
  }) {
    return Vehicle(
      id: id ?? this.id,
      vehicleTypeId: vehicleTypeId ?? this.vehicleTypeId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      plate: plate ?? this.plate,
      mileage: mileage ?? this.mileage,
    );
  }
}
