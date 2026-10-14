import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../vehicles/presentation/controllers/vehicles_provider.dart';
import '../../data/repositories/api_alert_repository.dart';
import '../../domain/entities/app_alert.dart';
import '../../domain/repositories/alert_repository.dart';

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return ApiAlertRepository();
});

class AlertsNotifier extends Notifier<List<AppAlert>> {
  AlertRepository get _repository {
    return ref.read(alertRepositoryProvider);
  }

  @override
  List<AppAlert> build() {
    ref.watch(vehiclesProvider.select((state) => state.vehicles.length));

    Future<void>.microtask(refresh);

    return const [];
  }

  Future<void> refresh() async {
    final items = await _repository.getAll();
    final vehicles = ref.read(vehiclesProvider).vehicles;

    final enriched =
        items.map((alert) {
          for (final vehicle in vehicles) {
            if (vehicle.id == alert.vehicleId) {
              return alert.copyWith(
                vehicleLabel: '${vehicle.displayName} (${vehicle.plate})',
              );
            }
          }

          return alert.copyWith(vehicleLabel: 'Vehículo');
        }).toList()..sort((a, b) {
          if (a.isRead != b.isRead) {
            return a.isRead ? 1 : -1;
          }

          return b.createdAt.compareTo(a.createdAt);
        });

    state = List.unmodifiable(enriched);
  }

  Future<int> generate() async {
    final created = await _repository.generate();
    await refresh();
    return created;
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);

    state = [
      for (final alert in state)
        if (alert.id == id) alert.copyWith(isRead: true) else alert,
    ];
  }
}

final alertsProvider = NotifierProvider<AlertsNotifier, List<AppAlert>>(
  AlertsNotifier.new,
);
