import '../entities/mileage_record.dart';

abstract interface class MileageRepository {
  Future<List<MileageRecord>> getByVehicleId(String vehicleId);

  Future<MileageRecord> create(MileageRecord record);
}
