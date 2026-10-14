import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../maintenance/presentation/controllers/upcoming_maintenance_provider.dart';
import '../../domain/entities/app_alert.dart';
import '../controllers/alerts_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);
    final upcoming = ref.watch(upcomingMaintenanceProvider);
    final unreadCount = alerts.where((alert) => !alert.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Alertas ($unreadCount)'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () async {
              await Future.wait([
                ref.read(alertsProvider.notifier).refresh(),
                ref.read(upcomingMaintenanceProvider.notifier).refresh(),
              ]);
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(alertsProvider.notifier).refresh(),
            ref.read(upcomingMaintenanceProvider.notifier).refresh(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Próximos mantenimientos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            if (upcoming.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No hay mantenimientos próximos dentro de los límites configurados.',
                  ),
                ),
              )
            else
              ...upcoming
                  .take(3)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.maintenanceType,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.vehicle} (${item.plate})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(_upcomingDescription(item)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Notificaciones',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '$unreadCount sin leer',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (alerts.isEmpty)
              const _EmptyAlerts()
            else
              ...alerts.map((alert) {
                final visual = _visualFor(alert);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Opacity(
                    opacity: alert.isRead ? 0.65 : 1,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: visual.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(visual.icon, color: visual.color),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alert.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    alert.vehicleLabel,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(alert.description),
                                  if (!alert.isRead) ...[
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () async {
                                        await ref
                                            .read(alertsProvider.notifier)
                                            .markAsRead(alert.id);
                                      },
                                      child: const Text('Marcar como leída'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  static String _upcomingDescription(dynamic item) {
    final parts = <String>[];

    if (item.remainingKm != null) {
      final km = item.remainingKm as int;

      parts.add(km < 0 ? 'Superado por ${km.abs()} km' : 'Faltan $km km');
    }

    if (item.remainingDays != null) {
      final days = item.remainingDays as int;

      parts.add(
        days < 0
            ? 'Vencido hace ${days.abs()} día(s)'
            : days == 0
            ? 'Programado para hoy'
            : 'Faltan $days día(s)',
      );
    }

    return parts.isEmpty ? 'Próximo mantenimiento' : parts.join(' · ');
  }

  static _AlertVisual _visualFor(AppAlert alert) {
    switch (alert.sourceType) {
      case AlertSourceType.maintenanceMileage:
      case AlertSourceType.maintenanceDate:
        return _AlertVisual(
          icon: Icons.build_outlined,
          color: alert.level == AlertLevel.critical
              ? AppColors.error
              : AppColors.warning,
        );

      case AlertSourceType.documentExpiration:
        return _AlertVisual(
          icon: Icons.description_outlined,
          color: alert.level == AlertLevel.critical
              ? AppColors.error
              : AppColors.warning,
        );
    }
  }
}

class _EmptyAlerts extends StatelessWidget {
  const _EmptyAlerts();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 46,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 12),
            Text(
              'No tienes alertas pendientes.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertVisual {
  const _AlertVisual({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}
