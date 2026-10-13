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
            color: AppColors.warning,
            title: 'Revisi\u00F3n t\u00E9cnico-mec\u00E1nica pr\u00F3xima a vencer',
            description: 'El documento vence el 15 de noviembre de 2026.',
          ),
          SizedBox(height: 12),
          _NotificationCard(
            icon: Icons.build_outlined,
            color: AppColors.primary,
            title: 'Pr\u00F3ximo mantenimiento',
            description:
                'Faltan 5.000 km para el pr\u00F3ximo cambio de aceite.',
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;

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
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
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
                    style: const TextStyle(color: AppColors.textSecondary),
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
