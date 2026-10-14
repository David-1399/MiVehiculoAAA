class MileageRecord {
  const MileageRecord({
    required this.id,
    required this.vehicleId,
    required this.mileage,
    required this.recordedAt,
    required this.createdAt,
  });

  final String id;
  final String vehicleId;
  final int mileage;
  final DateTime recordedAt;
  final DateTime createdAt;
}
