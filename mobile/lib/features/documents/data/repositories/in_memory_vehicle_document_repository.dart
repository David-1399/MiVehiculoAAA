import '../../domain/entities/vehicle_document.dart';
import '../../domain/repositories/vehicle_document_repository.dart';

class InMemoryVehicleDocumentRepository implements VehicleDocumentRepository {
  final List<VehicleDocument> _items = [];

  @override
  Future<List<VehicleDocument>> getByVehicleId(String vehicleId) async {
    final result = _items.where((item) => item.vehicleId == vehicleId).toList()
      ..sort((a, b) => b.issueDate.compareTo(a.issueDate));

    return List.unmodifiable(result);
  }

  @override
  Future<VehicleDocument> create(VehicleDocument document) async {
    _items.add(document);
    return document;
  }

  @override
  Future<VehicleDocument> update(VehicleDocument document) async {
    final index = _items.indexWhere((item) => item.id == document.id);

    if (index == -1) {
      throw StateError('Documento no encontrado.');
    }

    _items[index] = document;
    return document;
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
  }
}
