import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/catalogs/domain/entities/catalog_bundle.dart';
import '../../data/repositories/in_memory_maintenance_repository.dart';
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
  return InMemoryMaintenanceRepository();
});

class MaintenanceState {
  const MaintenanceState({
    this.items = const [],
    this.selectedMaintenanceId,
    this.filter = MaintenanceFilter.all,
  });

  final List<MaintenanceRecord> items;
  final String? selectedMaintenanceId;
  final MaintenanceFilter filter;

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
  }) {
    return MaintenanceState(
      items: items ?? this.items,
      selectedMaintenanceId:
          selectedMaintenanceId ?? this.selectedMaintenanceId,
      filter: filter ?? this.filter,
    );
  }
}

class MaintenanceNotifier extends Notifier<MaintenanceState> {
  MaintenanceRepository get _repository {
    return ref.read(maintenanceRepositoryProvider);
  }

  @override
  MaintenanceState build() {
    return MaintenanceState(items: _repository.getAll());
  }

  MaintenanceRecord addMaintenance({
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
  }) {
    final now = DateTime.now();

    final maintenance = MaintenanceRecord(
      id: now.microsecondsSinceEpoch.toString(),
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

    _repository.create(maintenance);

    state = MaintenanceState(
      items: _repository.getAll(),
      selectedMaintenanceId: maintenance.id,
      filter: state.filter,
    );

    return maintenance;
  }

  void selectMaintenance(String id) {
    state = state.copyWith(selectedMaintenanceId: id);
  }

  void setFilter(MaintenanceFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void deleteMaintenance(String id) {
    _repository.delete(id);

    state = MaintenanceState(items: _repository.getAll(), filter: state.filter);
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
