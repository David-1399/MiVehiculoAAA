import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../vehicles/presentation/controllers/vehicles_provider.dart';
import '../../data/repositories/api_mileage_repository.dart';
import '../../domain/entities/mileage_record.dart';
import '../../domain/repositories/mileage_repository.dart';

final mileageRepositoryProvider = Provider<MileageRepository>((ref) {
  return ApiMileageRepository();
});

class MileageState {
  const MileageState({this.items = const [], this.loading = false});

  final List<MileageRecord> items;
  final bool loading;

  List<MileageRecord> forVehicle(String vehicleId) {
    final result = items.where((item) => item.vehicleId == vehicleId).toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    return result;
  }
}

class MileageNotifier extends Notifier<MileageState> {
  MileageRepository get _repository {
    return ref.read(mileageRepositoryProvider);
  }

  @override
  MileageState build() {
    final vehicleId = ref.watch(
      vehiclesProvider.select((state) => state.selectedVehicleId),
    );

    if (vehicleId != null) {
      Future<void>.microtask(() => refresh(vehicleId));
    }

    return const MileageState(loading: true);
  }

  Future<void> refresh(String vehicleId) async {
    state = MileageState(items: state.items, loading: true);

    final items = await _repository.getByVehicleId(vehicleId);

    state = MileageState(items: items);
  }

  Future<MileageRecord> addReading({
    required String vehicleId,
    required int mileage,
    DateTime? recordedAt,
  }) async {
    final now = DateTime.now();

    final record = MileageRecord(
      id: '',
      vehicleId: vehicleId,
      mileage: mileage,
      recordedAt: recordedAt ?? now,
      createdAt: now,
    );

    final saved = await _repository.create(record);
    final items = await _repository.getByVehicleId(vehicleId);

    state = MileageState(items: items);

    return saved;
  }
}

final mileageProvider = NotifierProvider<MileageNotifier, MileageState>(
  MileageNotifier.new,
);
