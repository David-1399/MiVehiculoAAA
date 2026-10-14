import '../entities/vehicle.dart';

abstract interface class VehicleRepository {
  Future<List<Vehicle>> getAll();

  Future<Vehicle> add(Vehicle vehicle);

  Future<Vehicle> update(Vehicle vehicle);

  Future<Vehicle?> findById(String id);

  Future<void> deleteById(String id);
}
