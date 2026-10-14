import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/vehicle.dart';

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
  @override
  VehiclesState build() {
    return const VehiclesState();
  }

  Vehicle addVehicle({
    required String vehicleTypeId,
    required String brand,
    required String model,
    required int year,
    required String plate,
    required int mileage,
  }) {
    final vehicle = Vehicle(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      vehicleTypeId: vehicleTypeId,
      brand: brand.trim(),
      model: model.trim(),
      year: year,
      plate: plate.trim().toUpperCase(),
      mileage: mileage,
    );

    state = VehiclesState(
      vehicles: [...state.vehicles, vehicle],
      selectedVehicleId: vehicle.id,
    );

    return vehicle;
  }

  void selectVehicle(String id) {
    state = state.copyWith(selectedVehicleId: id);
  }

  void updateMileage({required String vehicleId, required int mileage}) {
    final updatedVehicles = state.vehicles.map((vehicle) {
      if (vehicle.id != vehicleId) {
        return vehicle;
      }

      return vehicle.copyWith(mileage: mileage);
    }).toList();

    state = VehiclesState(
      vehicles: updatedVehicles,
      selectedVehicleId: state.selectedVehicleId,
    );
  }
}

final vehiclesProvider = NotifierProvider<VehiclesNotifier, VehiclesState>(
  VehiclesNotifier.new,
);
