import '../entities/vehicle.dart';

abstract interface class VehicleRepository {
  List<Vehicle> getAll();

  Vehicle add(Vehicle vehicle);

  Vehicle update(Vehicle vehicle);

  Vehicle? findById(String id);

  void deleteById(String id);
}
