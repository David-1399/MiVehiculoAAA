import '../../domain/entities/mileage_record.dart';
import '../../domain/repositories/mileage_repository.dart';

class InMemoryMileageRepository implements MileageRepository {
  final List<MileageRecord> _items = [];

  @override
  Future<List<MileageRecord>> getByVehicleId(String vehicleId) async {
    final items = _items.where((item) => item.vehicleId == vehicleId).toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    return List.unmodifiable(items);
  }

  @override
  Future<MileageRecord> create(MileageRecord record) async {
    _items.add(record);
    return record;
  }
}
