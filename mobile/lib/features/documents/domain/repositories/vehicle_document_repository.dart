import '../entities/vehicle_document.dart';

abstract interface class VehicleDocumentRepository {
  Future<List<VehicleDocument>> getByVehicleId(String vehicleId);

  Future<VehicleDocument> create(VehicleDocument document);

  Future<VehicleDocument> update(VehicleDocument document);

  Future<void> delete(String id);
}
