class Vehicle {
  const Vehicle({
    required this.id,
    required this.type,
    required this.brand,
    required this.model,
    required this.year,
    required this.plate,
    required this.mileage,
  });

  final String id;
  final String type;
  final String brand;
  final String model;
  final int year;
  final String plate;
  final int mileage;

  String get displayName => '$brand $model';
}
