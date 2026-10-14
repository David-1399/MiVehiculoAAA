import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/in_memory_vehicle_repository.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return InMemoryVehicleRepository();
});

class VehiclesState {
  const VehiclesState({this.vehicles = const [], this.selectedVehicleId});

  final List<Vehicle> vehicles;
  final String? selectedVehicleId;

  Vehicle? get selectedVehicle {
    if (vehicles.isEmpty) {
      return null;
    }

    if (selectedVehicleId == null) {
      return vehicles.first;
    }

    for (final vehicle in vehicles) {
      if (vehicle.id == selectedVehicleId) {
        return vehicle;
      }
    }

    return vehicles.first;
  }

  VehiclesState copyWith({List<Vehicle>? vehicles, String? selectedVehicleId}) {
    return VehiclesState(
      vehicles: vehicles ?? this.vehicles,
      selectedVehicleId: selectedVehicleId ?? this.selectedVehicleId,
    );
  }
}

class VehiclesNotifier extends Notifier<VehiclesState> {
  VehicleRepository get _repository {
    return ref.read(vehicleRepositoryProvider);
  }

  @override
  VehiclesState build() {
    return VehiclesState(vehicles: _repository.getAll());
  }

  Vehicle addVehicle({
    required String vehicleTypeId,
    required String brand,
    required String model,
    required int year,
    required String plate,
    required int mileage,
  }) {
    final normalizedPlate = plate.trim().toUpperCase();

    _validateUniquePlate(normalizedPlate);

    final vehicle = Vehicle(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      vehicleTypeId: vehicleTypeId,
      brand: brand.trim(),
      model: model.trim(),
      year: year,
      plate: normalizedPlate,
      mileage: mileage,
    );

    final saved = _repository.add(vehicle);

    state = VehiclesState(
      vehicles: _repository.getAll(),
      selectedVehicleId: saved.id,
    );

    return saved;
  }

  Vehicle updateVehicle({
    required String vehicleId,
    required String vehicleTypeId,
    required String brand,
    required String model,
    required int year,
    required String plate,
  }) {
    final current = _repository.findById(vehicleId);

    if (current == null) {
      throw StateError('El vehículo que intentas actualizar no existe.');
    }

    final normalizedPlate = plate.trim().toUpperCase();

    _validateUniquePlate(normalizedPlate, excludingVehicleId: vehicleId);

    final updated = current.copyWith(
      vehicleTypeId: vehicleTypeId,
      brand: brand.trim(),
      model: model.trim(),
      year: year,
      plate: normalizedPlate,

      // El kilometraje se conserva. Su modificación debe
      // hacerse desde el módulo de kilometraje para mantener
      // consistencia con el historial.
      mileage: current.mileage,
    );

    final saved = _repository.update(updated);

    state = VehiclesState(
      vehicles: _repository.getAll(),
      selectedVehicleId: saved.id,
    );

    return saved;
  }

  void deleteVehicle(String vehicleId) {
    final current = _repository.findById(vehicleId);

    if (current == null) {
      throw StateError('El vehículo que intentas eliminar no existe.');
    }

    _repository.deleteById(vehicleId);

    final remaining = _repository.getAll();

    String? nextSelectedId;

    if (remaining.isNotEmpty) {
      final currentSelection = state.selectedVehicleId;

      final selectionStillExists =
          currentSelection != null &&
          remaining.any((vehicle) => vehicle.id == currentSelection);

      nextSelectedId = selectionStillExists
          ? currentSelection
          : remaining.first.id;
    }

    state = VehiclesState(
      vehicles: remaining,
      selectedVehicleId: nextSelectedId,
    );
  }

  void selectVehicle(String id) {
    state = state.copyWith(selectedVehicleId: id);
  }

  void updateMileage({required String vehicleId, required int mileage}) {
    final current = _repository.findById(vehicleId);

    if (current == null) {
      throw StateError('El vehículo no existe.');
    }

    if (mileage < current.mileage) {
      throw ArgumentError('El kilometraje no puede ser menor al actual.');
    }

    _repository.update(current.copyWith(mileage: mileage));

    state = VehiclesState(
      vehicles: _repository.getAll(),
      selectedVehicleId: state.selectedVehicleId,
    );
  }

  void _validateUniquePlate(String plate, {String? excludingVehicleId}) {
    final duplicated = _repository.getAll().any((vehicle) {
      return vehicle.id != excludingVehicleId &&
          vehicle.plate.trim().toUpperCase() == plate;
    });

    if (duplicated) {
      throw ArgumentError('Ya existe un vehículo registrado con esa placa.');
    }
  }
}

final vehiclesProvider = NotifierProvider<VehiclesNotifier, VehiclesState>(
  VehiclesNotifier.new,
);
