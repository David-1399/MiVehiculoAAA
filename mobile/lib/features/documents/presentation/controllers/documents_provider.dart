import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../vehicles/presentation/controllers/vehicles_provider.dart';
import '../../data/repositories/api_vehicle_document_repository.dart';
import '../../domain/entities/vehicle_document.dart';
import '../../domain/repositories/vehicle_document_repository.dart';

final vehicleDocumentRepositoryProvider = Provider<VehicleDocumentRepository>((
  ref,
) {
  return ApiVehicleDocumentRepository();
});

class DocumentsState {
  const DocumentsState({
    this.items = const [],
    this.selectedDocumentId,
    this.loading = false,
  });

  final List<VehicleDocument> items;
  final String? selectedDocumentId;
  final bool loading;

  VehicleDocument? get selectedDocument {
    final id = selectedDocumentId;

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

  List<VehicleDocument> forVehicle(String vehicleId) {
    final result = items.where((item) => item.vehicleId == vehicleId).toList()
      ..sort((a, b) {
        final aDate = a.expirationDate;
        final bDate = b.expirationDate;

        if (aDate == null && bDate == null) {
          return b.issueDate.compareTo(a.issueDate);
        }

        if (aDate == null) {
          return 1;
        }

        if (bDate == null) {
          return -1;
        }

        return aDate.compareTo(bDate);
      });

    return result;
  }
}

class DocumentsNotifier extends Notifier<DocumentsState> {
  VehicleDocumentRepository get _repository {
    return ref.read(vehicleDocumentRepositoryProvider);
  }

  @override
  DocumentsState build() {
    final vehicleId = ref.watch(
      vehiclesProvider.select((state) => state.selectedVehicleId),
    );

    if (vehicleId != null) {
      Future<void>.microtask(() => refresh(vehicleId));
    }

    return const DocumentsState(loading: true);
  }

  Future<void> refresh(String vehicleId) async {
    final items = await _repository.getByVehicleId(vehicleId);
    state = DocumentsState(items: items);
  }

  Future<VehicleDocument> addDocument({
    required String vehicleId,
    required String documentTypeId,
    required String number,
    required DateTime issueDate,
    DateTime? expirationDate,
    String? evidencePath,
  }) async {
    final now = DateTime.now();

    final document = VehicleDocument(
      id: '',
      vehicleId: vehicleId,
      documentTypeId: documentTypeId,
      number: number.trim(),
      issueDate: issueDate,
      expirationDate: expirationDate,
      evidencePath: _nullableText(evidencePath),
      createdAt: now,
      updatedAt: now,
    );

    final saved = await _repository.create(document);
    final items = await _repository.getByVehicleId(vehicleId);

    state = DocumentsState(items: items, selectedDocumentId: saved.id);

    return saved;
  }

  void selectDocument(String id) {
    state = DocumentsState(items: state.items, selectedDocumentId: id);
  }

  Future<void> deleteDocument(String id) async {
    final vehicleId = ref.read(vehiclesProvider).selectedVehicleId;

    await _repository.delete(id);

    if (vehicleId == null) {
      state = const DocumentsState();
      return;
    }

    final items = await _repository.getByVehicleId(vehicleId);
    state = DocumentsState(items: items);
  }

  String? _nullableText(String? value) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }
}

final documentsProvider = NotifierProvider<DocumentsNotifier, DocumentsState>(
  DocumentsNotifier.new,
);
