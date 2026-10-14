import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/catalogs/presentation/controllers/catalogs_provider.dart';
import '../../../documents/domain/entities/vehicle_document.dart';
import '../../../documents/presentation/controllers/documents_provider.dart';
import '../../../maintenance/presentation/controllers/maintenance_provider.dart';
import '../../../vehicles/presentation/controllers/vehicles_provider.dart';
import '../../domain/entities/app_alert.dart';

final alertsProvider = Provider<List<AppAlert>>((ref) {
  final vehiclesState = ref.watch(vehiclesProvider);

  final maintenanceState = ref.watch(maintenanceProvider);

  final documentsState = ref.watch(documentsProvider);

  final catalogs = ref.watch(catalogsProvider).asData?.value;

  final now = DateTime.now();

  final alerts = <AppAlert>[];

  for (final vehicle in vehiclesState.vehicles) {
    final vehicleLabel = '${vehicle.displayName} (${vehicle.plate})';

    // ------------------------------------------------------
    // MANTENIMIENTOS POR KILOMETRAJE
    // ------------------------------------------------------

    final vehicleMaintenances = maintenanceState.items.where(
      (item) => item.vehicleId == vehicle.id,
    );

    for (final maintenance in vehicleMaintenances) {
      final typeName =
          catalogs?.maintenanceTypeById(maintenance.maintenanceTypeId)?.name ??
          'Mantenimiento';

      final nextMileage = maintenance.nextMileage;

      if (nextMileage != null) {
        final distance = nextMileage - vehicle.mileage;

        // Se alerta cuando ya vencio o faltan maximo 1000 km.
        if (distance <= 1000) {
          if (distance < 0) {
            alerts.add(
              AppAlert(
                id: 'maintenance-mileage-overdue-${maintenance.id}',
                vehicleId: vehicle.id,
                vehicleLabel: vehicleLabel,
                title: '$typeName vencido por kilometraje',
                description:
                    'El mantenimiento estaba programado para $nextMileage km y el vehículo registra ${vehicle.mileage} km.',
                level: AlertLevel.critical,
                sourceType: AlertSourceType.maintenanceMileage,
                distanceKm: distance,
              ),
            );
          } else {
            alerts.add(
              AppAlert(
                id: 'maintenance-mileage-${maintenance.id}',
                vehicleId: vehicle.id,
                vehicleLabel: vehicleLabel,
                title: 'Próximo mantenimiento: $typeName',
                description: distance == 0
                    ? 'El mantenimiento corresponde al kilometraje actual.'
                    : 'Faltan $distance km para el próximo mantenimiento.',
                level: distance <= 250
                    ? AlertLevel.critical
                    : AlertLevel.warning,
                sourceType: AlertSourceType.maintenanceMileage,
                distanceKm: distance,
              ),
            );
          }
        }
      }

      // ----------------------------------------------------
      // MANTENIMIENTOS POR FECHA
      // ----------------------------------------------------

      final nextDate = maintenance.nextDate;

      if (nextDate != null) {
        final today = DateTime(now.year, now.month, now.day);

        final due = DateTime(nextDate.year, nextDate.month, nextDate.day);

        final days = due.difference(today).inDays;

        // Se alerta cuando esta vencido o dentro de 30 dias.
        if (days <= 30) {
          alerts.add(
            AppAlert(
              id: 'maintenance-date-${maintenance.id}',
              vehicleId: vehicle.id,
              vehicleLabel: vehicleLabel,
              title: days < 0
                  ? '$typeName vencido por fecha'
                  : 'Próximo mantenimiento: $typeName',
              description: days < 0
                  ? 'La fecha programada del mantenimiento ya venció.'
                  : days == 0
                  ? 'El mantenimiento está programado para hoy.'
                  : 'Faltan $days días para la fecha programada.',
              level: days <= 7 ? AlertLevel.critical : AlertLevel.warning,
              sourceType: AlertSourceType.maintenanceDate,
              dueDate: due,
            ),
          );
        }
      }
    }

    // ------------------------------------------------------
    // DOCUMENTOS
    // ------------------------------------------------------

    final vehicleDocuments = documentsState.items.where(
      (item) => item.vehicleId == vehicle.id,
    );

    for (final document in vehicleDocuments) {
      final status = document.statusAt(now);

      if (status != VehicleDocumentStatus.expired &&
          status != VehicleDocumentStatus.expiringSoon) {
        continue;
      }

      final typeName =
          catalogs?.documentTypeById(document.documentTypeId)?.name ??
          'Documento';

      final expiration = document.expirationDate;

      if (expiration == null) {
        continue;
      }

      final today = DateTime(now.year, now.month, now.day);

      final due = DateTime(expiration.year, expiration.month, expiration.day);

      final days = due.difference(today).inDays;

      alerts.add(
        AppAlert(
          id: 'document-${document.id}',
          vehicleId: vehicle.id,
          vehicleLabel: vehicleLabel,
          title: status == VehicleDocumentStatus.expired
              ? '$typeName vencido'
              : '$typeName próximo a vencer',
          description: status == VehicleDocumentStatus.expired
              ? 'El documento venció hace ${days.abs()} día(s).'
              : days == 0
              ? 'El documento vence hoy.'
              : 'El documento vence en $days día(s).',
          level: status == VehicleDocumentStatus.expired
              ? AlertLevel.critical
              : days <= 7
              ? AlertLevel.critical
              : AlertLevel.warning,
          sourceType: AlertSourceType.documentExpiration,
          dueDate: due,
        ),
      );
    }
  }

  // Criticas primero.
  // Luego alertas con menor distancia/fecha mas cercana.
  alerts.sort((a, b) {
    final levelCompare = _priority(b.level).compareTo(_priority(a.level));

    if (levelCompare != 0) {
      return levelCompare;
    }

    if (a.distanceKm != null && b.distanceKm != null) {
      return a.distanceKm!.abs().compareTo(b.distanceKm!.abs());
    }

    if (a.dueDate != null && b.dueDate != null) {
      return a.dueDate!.compareTo(b.dueDate!);
    }

    return a.title.compareTo(b.title);
  });

  return List.unmodifiable(alerts);
});

int _priority(AlertLevel level) {
  switch (level) {
    case AlertLevel.info:
      return 1;
    case AlertLevel.warning:
      return 2;
    case AlertLevel.critical:
      return 3;
  }
}
