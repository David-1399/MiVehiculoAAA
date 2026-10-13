import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_alert.dart';

class AlertsNotifier extends Notifier<List<AppAlert>> {
  @override
  List<AppAlert> build() {
    return const [
      AppAlert(
        id: 'maintenance-1',
        title: 'Cambio de aceite',
        description: 'Faltan 580 km para el pr\u00F3ximo cambio de aceite.',
        vehicle: 'Yamaha MT-03',
        level: 'warning',
        distanceKm: 580,
      ),
      AppAlert(
        id: 'document-1',
        title: 'Revisi\u00F3n t\u00E9cnico-mec\u00E1nica',
        description: 'El documento est\u00E1 pr\u00F3ximo a vencer.',
        vehicle: 'Mazda 3',
        level: 'warning',
      ),
    ];
  }
}

final alertsProvider = NotifierProvider<AlertsNotifier, List<AppAlert>>(
  AlertsNotifier.new,
);
