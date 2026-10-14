import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/in_memory_vehicle_document_repository.dart';
import '../../domain/entities/vehicle_document.dart';
import '../../domain/repositories/vehicle_document_repository.dart';

final vehicleDocumentRepositoryProvider = Provider<VehicleDocumentRepository>((
  ref,
) {
  return InMemoryVehicleDocumentRepository();
});

class DocumentsState {
  const DocumentsState({this.items = const [], this.selectedDocumentId});

  final List<VehicleDocument> items;
  final String? selectedDocumentId;

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
    return DocumentsState(items: _repository.getAll());
  }

  VehicleDocument addDocument({
    required String vehicleId,
    required String documentTypeId,
    required String number,
    required DateTime issueDate,
    DateTime? expirationDate,
    String? evidencePath,
  }) {
    final now = DateTime.now();

    final document = VehicleDocument(
      id: now.microsecondsSinceEpoch.toString(),
      vehicleId: vehicleId,
      documentTypeId: documentTypeId,
      number: number.trim(),
      issueDate: issueDate,
      expirationDate: expirationDate,
      evidencePath: _nullableText(evidencePath),
      createdAt: now,
      updatedAt: now,
    );

    _repository.create(document);

    state = DocumentsState(
      items: _repository.getAll(),
      selectedDocumentId: document.id,
    );

    return document;
  }

  void selectDocument(String id) {
    state = DocumentsState(items: state.items, selectedDocumentId: id);
  }

  void deleteDocument(String id) {
    _repository.delete(id);

    state = DocumentsState(items: _repository.getAll());
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
