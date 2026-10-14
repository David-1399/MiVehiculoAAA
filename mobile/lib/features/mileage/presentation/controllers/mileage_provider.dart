import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/in_memory_mileage_repository.dart';
import '../../domain/entities/mileage_record.dart';
import '../../domain/repositories/mileage_repository.dart';

final mileageRepositoryProvider = Provider<MileageRepository>((ref) {
  return InMemoryMileageRepository();
});

class MileageState {
  const MileageState({this.items = const []});

  final List<MileageRecord> items;

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
    return MileageState(items: _repository.getAll());
  }

  MileageRecord addReading({
    required String vehicleId,
    required int mileage,
    DateTime? recordedAt,
  }) {
    final now = DateTime.now();

    final record = MileageRecord(
      id: now.microsecondsSinceEpoch.toString(),
      vehicleId: vehicleId,
      mileage: mileage,
      recordedAt: recordedAt ?? now,
      createdAt: now,
    );

    _repository.create(record);

    state = MileageState(items: _repository.getAll());

    return record;
  }
}

final mileageProvider = NotifierProvider<MileageNotifier, MileageState>(
  MileageNotifier.new,
);
