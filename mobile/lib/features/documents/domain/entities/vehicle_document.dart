enum VehicleDocumentStatus { valid, expiringSoon, expired, noExpiration }

extension VehicleDocumentStatusX on VehicleDocumentStatus {
  String get label {
    switch (this) {
      case VehicleDocumentStatus.valid:
        return 'Vigente';
      case VehicleDocumentStatus.expiringSoon:
        return 'Próximo';
      case VehicleDocumentStatus.expired:
        return 'Vencido';
      case VehicleDocumentStatus.noExpiration:
        return 'Sin vencimiento';
    }
  }
}

class VehicleDocument {
  const VehicleDocument({
    required this.id,
    required this.vehicleId,
    required this.documentTypeId,
    required this.number,
    required this.issueDate,
    required this.createdAt,
    required this.updatedAt,
    this.expirationDate,
    this.evidencePath,
  });

  final String id;
  final String vehicleId;
  final String documentTypeId;

  final String number;
  final DateTime issueDate;
  final DateTime? expirationDate;
  final String? evidencePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleDocumentStatus statusAt(DateTime now, {int expiringSoonDays = 30}) {
    final expiration = expirationDate;

    if (expiration == null) {
      return VehicleDocumentStatus.noExpiration;
    }

    final today = DateTime(now.year, now.month, now.day);
    final expirationDay = DateTime(
      expiration.year,
      expiration.month,
      expiration.day,
    );

    if (expirationDay.isBefore(today)) {
      return VehicleDocumentStatus.expired;
    }

    final days = expirationDay.difference(today).inDays;

    if (days <= expiringSoonDays) {
      return VehicleDocumentStatus.expiringSoon;
    }

    return VehicleDocumentStatus.valid;
  }

  VehicleDocument copyWith({
    String? id,
    String? vehicleId,
    String? documentTypeId,
    String? number,
    DateTime? issueDate,
    DateTime? expirationDate,
    bool clearExpirationDate = false,
    String? evidencePath,
    bool clearEvidencePath = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleDocument(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      documentTypeId: documentTypeId ?? this.documentTypeId,
      number: number ?? this.number,
      issueDate: issueDate ?? this.issueDate,
      expirationDate: clearExpirationDate
          ? null
          : expirationDate ?? this.expirationDate,
      evidencePath: clearEvidencePath
          ? null
          : evidencePath ?? this.evidencePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
