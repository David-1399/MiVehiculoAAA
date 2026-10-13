import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver al inicio',
          onPressed: () {
            context.go(AppRoutes.dashboard);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Notificaciones'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _NotificationCard(
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.warning,
            title: 'Revisión técnico-mecánica próxima a vencer',
            description: 'El documento vence el 15 de noviembre de 2026.',
            time: 'Hoy',
          ),
          SizedBox(height: 12),
          _NotificationCard(
            icon: Icons.build_outlined,
            iconColor: AppColors.primary,
            title: 'Próximo mantenimiento',
            description: 'Faltan 5.000 km para el próximo cambio de aceite.',
            time: 'Ayer',
          ),
          SizedBox(height: 12),
          _NotificationCard(
            icon: Icons.check_circle_outline_rounded,
            iconColor: AppColors.success,
            title: 'Documento registrado',
            description: 'El SOAT fue registrado correctamente.',
            time: '20 Sep 2026',
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.time,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String time;

  @override
  Widget build(BuildContext context) {
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
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
