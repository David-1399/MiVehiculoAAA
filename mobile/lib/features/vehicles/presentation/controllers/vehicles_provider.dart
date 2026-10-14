import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/api_vehicle_repository.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return ApiVehicleRepository();
});

class VehiclesState {
  const VehiclesState({
    this.vehicles = const [],
    this.selectedVehicleId,
    this.loading = false,
  });

  final List<Vehicle> vehicles;
  final String? selectedVehicleId;
  final bool loading;

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

  VehiclesState copyWith({
    List<Vehicle>? vehicles,
    String? selectedVehicleId,
    bool clearSelectedVehicle = false,
    bool? loading,
  }) {
    return VehiclesState(
      vehicles: vehicles ?? this.vehicles,
      selectedVehicleId: clearSelectedVehicle
          ? null
          : selectedVehicleId ?? this.selectedVehicleId,
      loading: loading ?? this.loading,
    );
  }
}

class VehiclesNotifier extends Notifier<VehiclesState> {
  VehicleRepository get _repository {
    return ref.read(vehicleRepositoryProvider);
  }

  @override
  VehiclesState build() {
    Future<void>.microtask(refresh);
    return const VehiclesState(loading: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true);

    try {
      final vehicles = await _repository.getAll();

      String? selectedId = state.selectedVehicleId;

      if (vehicles.isEmpty) {
        selectedId = null;
      } else if (selectedId == null ||
          !vehicles.any((vehicle) => vehicle.id == selectedId)) {
        selectedId = vehicles.first.id;
      }

      state = VehiclesState(vehicles: vehicles, selectedVehicleId: selectedId);
    } catch (_) {
      state = state.copyWith(loading: false);
      rethrow;
    }
  }

  Future<Vehicle> addVehicle({
    required String vehicleTypeId,
    required String brand,
    required String model,
    required int year,
    required String plate,
    required int mileage,
  }) async {
    final vehicle = Vehicle(
      id: '',
      vehicleTypeId: vehicleTypeId,
      brand: brand.trim(),
      model: model.trim(),
      year: year,
      plate: plate.trim().toUpperCase(),
      mileage: mileage,
    );

    final saved = await _repository.add(vehicle);
    final vehicles = await _repository.getAll();

    state = VehiclesState(vehicles: vehicles, selectedVehicleId: saved.id);

    return saved;
  }

  Future<Vehicle> updateVehicle({
    required String vehicleId,
    required String vehicleTypeId,
    required String brand,
    required String model,
    required int year,
    required String plate,
  }) async {
    Vehicle? current;

    for (final vehicle in state.vehicles) {
      if (vehicle.id == vehicleId) {
        current = vehicle;
        break;
      }
    }

    if (current == null) {
      throw StateError('El vehículo que intentas actualizar no existe.');
    }

    final updated = current.copyWith(
      vehicleTypeId: vehicleTypeId,
      brand: brand.trim(),
      model: model.trim(),
      year: year,
      plate: plate.trim().toUpperCase(),
      mileage: current.mileage,
    );

    final saved = await _repository.update(updated);
    final vehicles = await _repository.getAll();

    state = VehiclesState(vehicles: vehicles, selectedVehicleId: saved.id);

    return saved;
  }

  Future<void> deleteVehicle(String vehicleId) async {
    await _repository.deleteById(vehicleId);

    final remaining = await _repository.getAll();

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
    final vehicles = state.vehicles.map((vehicle) {
      if (vehicle.id != vehicleId) {
        return vehicle;
      }

      return vehicle.copyWith(mileage: mileage);
    }).toList();

    state = VehiclesState(
      vehicles: vehicles,
      selectedVehicleId: state.selectedVehicleId,
    );
  }
}

final vehiclesProvider = NotifierProvider<VehiclesNotifier, VehiclesState>(
  VehiclesNotifier.new,
);
