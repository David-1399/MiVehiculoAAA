import '../entities/vehicle_document.dart';

abstract interface class VehicleDocumentRepository {
  List<VehicleDocument> getAll();

  List<VehicleDocument> getByVehicleId(String vehicleId);

  VehicleDocument? getById(String id);

  VehicleDocument create(VehicleDocument document);

  VehicleDocument update(VehicleDocument document);

  void delete(String id);
}
