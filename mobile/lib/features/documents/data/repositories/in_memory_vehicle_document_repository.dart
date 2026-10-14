import '../../domain/entities/vehicle_document.dart';
import '../../domain/repositories/vehicle_document_repository.dart';

class InMemoryVehicleDocumentRepository implements VehicleDocumentRepository {
  final List<VehicleDocument> _items = [];

  @override
  List<VehicleDocument> getAll() {
    return List.unmodifiable(_items);
  }

  @override
  List<VehicleDocument> getByVehicleId(String vehicleId) {
    final result = _items.where((item) => item.vehicleId == vehicleId).toList()
      ..sort((a, b) => b.issueDate.compareTo(a.issueDate));

    return List.unmodifiable(result);
  }

  @override
  VehicleDocument? getById(String id) {
    for (final item in _items) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }

  @override
  VehicleDocument create(VehicleDocument document) {
    _items.add(document);
    return document;
  }

  @override
  VehicleDocument update(VehicleDocument document) {
    final index = _items.indexWhere((item) => item.id == document.id);

    if (index == -1) {
      throw StateError('Documento no encontrado.');
    }

    _items[index] = document;
    return document;
  }

  @override
  void delete(String id) {
    _items.removeWhere((item) => item.id == id);
  }
}
