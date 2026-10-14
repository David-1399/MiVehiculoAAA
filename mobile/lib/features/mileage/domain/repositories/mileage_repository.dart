import '../entities/mileage_record.dart';

abstract interface class MileageRepository {
  List<MileageRecord> getAll();

  List<MileageRecord> getByVehicleId(String vehicleId);

  MileageRecord create(MileageRecord record);
}
