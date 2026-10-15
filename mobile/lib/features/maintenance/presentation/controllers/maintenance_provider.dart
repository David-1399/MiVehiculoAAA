import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/catalogs/domain/entities/catalog_bundle.dart';
import '../../../vehicles/presentation/controllers/vehicles_provider.dart';
import '../../data/repositories/api_maintenance_repository.dart';
import '../../domain/entities/maintenance_record.dart';
import '../../domain/repositories/maintenance_repository.dart';

enum MaintenanceFilter { all, preventive, corrective }

extension MaintenanceFilterX on MaintenanceFilter {
  String get label {
    switch (this) {
      case MaintenanceFilter.all:
        return 'Todos';
      case MaintenanceFilter.preventive:
        return 'Preventivos';
      case MaintenanceFilter.corrective:
        return 'Correctivos';
    }
  }
}

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) {
  return ApiMaintenanceRepository();
});

class MaintenanceState {
  const MaintenanceState({
    this.items = const [],
    this.selectedMaintenanceId,
    this.filter = MaintenanceFilter.all,
    this.loading = false,
  });

  final List<MaintenanceRecord> items;
  final String? selectedMaintenanceId;
  final MaintenanceFilter filter;
  final bool loading;

  MaintenanceRecord? get selectedMaintenance {
    final id = selectedMaintenanceId;

    if (id == null) {
      return null;
    }

    for (final item in items) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }

  List<MaintenanceRecord> forVehicle(String vehicleId, CatalogBundle catalogs) {
    final vehicleItems =
        items.where((item) => item.vehicleId == vehicleId).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    if (filter == MaintenanceFilter.all) {
      return vehicleItems;
    }

    final expectedCategory = filter == MaintenanceFilter.preventive
        ? 'preventive'
        : 'corrective';

    return vehicleItems.where((item) {
      final type = catalogs.maintenanceTypeById(item.maintenanceTypeId);
      return type?.attributes['category'] == expectedCategory;
    }).toList();
  }

  MaintenanceState copyWith({
    List<MaintenanceRecord>? items,
    String? selectedMaintenanceId,
    MaintenanceFilter? filter,
    bool? loading,
  }) {
    return MaintenanceState(
      items: items ?? this.items,
      selectedMaintenanceId:
          selectedMaintenanceId ?? this.selectedMaintenanceId,
      filter: filter ?? this.filter,
      loading: loading ?? this.loading,
    );
  }
}

class MaintenanceNotifier extends Notifier<MaintenanceState> {
  MaintenanceRepository get _repository {
    return ref.read(maintenanceRepositoryProvider);
  }

  @override
  MaintenanceState build() {
    final vehicleId = ref.watch(
      vehiclesProvider.select((state) => state.selectedVehicleId),
    );

    if (vehicleId != null) {
      Future<void>.microtask(() => refresh(vehicleId));
    }

    return const MaintenanceState(loading: true);
  }

  Future<void> refresh(String vehicleId) async {
    final filter = state.filter;
    final selectedId = state.selectedMaintenanceId;

    state = state.copyWith(loading: true);

    final items = await _repository.getByVehicleId(vehicleId);

    state = MaintenanceState(
      items: items,
      selectedMaintenanceId: selectedId,
      filter: filter,
    );
  }

  Future<MaintenanceRecord> addMaintenance({
    required String vehicleId,
    required String maintenanceTypeId,
    required DateTime date,
    required int mileage,
    required int cost,
    String? workshop,
    String? observations,
    int? nextMileage,
    DateTime? nextDate,
    String? evidencePath,
  }) async {
    final now = DateTime.now();

    final maintenance = MaintenanceRecord(
      id: '',
      vehicleId: vehicleId,
      maintenanceTypeId: maintenanceTypeId,
      date: date,
      mileage: mileage,
      cost: cost,
      workshop: _nullableText(workshop),
      observations: _nullableText(observations),
      nextMileage: nextMileage,
      nextDate: nextDate,
      evidencePath: _nullableText(evidencePath),
      createdAt: now,
      updatedAt: now,
    );

    final saved = await _repository.create(maintenance);
    final items = await _repository.getByVehicleId(vehicleId);

    state = MaintenanceState(
      items: items,
      selectedMaintenanceId: saved.id,
      filter: state.filter,
    );

    return saved;
  }

  void selectMaintenance(String id) {
    state = state.copyWith(selectedMaintenanceId: id);
  }

  void setFilter(MaintenanceFilter filter) {
    state = state.copyWith(filter: filter);
  }

  Future<MaintenanceRecord> updateMaintenance({
    required MaintenanceRecord current,
    required String maintenanceTypeId,
    required DateTime date,
    required int mileage,
    required int cost,
    String? workshop,
    String? observations,
    int? nextMileage,
    DateTime? nextDate,
  }) async {
    final updated = MaintenanceRecord(
      id: current.id,
      vehicleId: current.vehicleId,
      maintenanceTypeId: maintenanceTypeId,
      date: date,
      mileage: mileage,
      cost: cost,
      workshop: _nullableText(workshop),
      observations: _nullableText(observations),
      nextMileage: nextMileage,
      nextDate: nextDate,
      evidencePath: current.evidencePath,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );

    final saved = await _repository.update(updated);
    final items = await _repository.getByVehicleId(current.vehicleId);

    state = MaintenanceState(
      items: items,
      selectedMaintenanceId: saved.id,
      filter: state.filter,
    );

    return saved;
  }

  Future<void> deleteMaintenance(String id) async {
    final vehicleId = ref.read(vehiclesProvider).selectedVehicleId;

    await _repository.delete(id);

    if (vehicleId == null) {
      state = MaintenanceState(filter: state.filter);
      return;
    }

    final items = await _repository.getByVehicleId(vehicleId);

    state = MaintenanceState(items: items, filter: state.filter);
  }

  String? _nullableText(String? value) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }
}

final maintenanceProvider =
    NotifierProvider<MaintenanceNotifier, MaintenanceState>(
      MaintenanceNotifier.new,
    );
