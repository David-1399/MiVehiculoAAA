import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../domain/entities/app_alert.dart';
import '../controllers/alerts_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Alertas (${alerts.length})')),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: alerts.isEmpty
          ? const _EmptyAlerts()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              separatorBuilder: (_, _) {
                return const SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                final alert = alerts[index];

                final visual = _visualFor(alert);

                return Card(
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  _AlertVisual _visualFor(AppAlert alert) {
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 52,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 14),
            Text(
              'No tienes alertas pendientes.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              'Las alertas aparecerán automáticamente según mantenimientos y vencimientos registrados.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
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
