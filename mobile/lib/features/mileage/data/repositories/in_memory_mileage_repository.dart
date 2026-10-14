import '../../domain/entities/mileage_record.dart';
import '../../domain/repositories/mileage_repository.dart';

class InMemoryMileageRepository implements MileageRepository {
  final List<MileageRecord> _items = [];

  @override
  List<MileageRecord> getAll() {
    return List.unmodifiable(_items);
  }

  @override
  List<MileageRecord> getByVehicleId(String vehicleId) {
    final items = _items.where((item) => item.vehicleId == vehicleId).toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    return List.unmodifiable(items);
  }

  @override
  MileageRecord create(MileageRecord record) {
    _items.add(record);
    return record;
  }
}
