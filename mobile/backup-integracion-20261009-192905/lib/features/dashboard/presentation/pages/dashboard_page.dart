import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MiVehiculoAAA'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesiÃ³n',
            onPressed: () {
              context.go(AppRoutes.login);
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Hola', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            const Text(
              'Este es el resumen general de tus vehÃ­culos.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.directions_car_outlined,
                    value: '0',
                    label: 'VehÃ­culos',
                    color: AppColors.primary,
                    onTap: () {
                      context.push(AppRoutes.vehicles);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.notifications_none_rounded,
                    value: '0',
                    label: 'Alertas',
                    color: AppColors.warning,
                    onTap: () {
                      context.push(AppRoutes.notifications);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Mis vehÃ­culos',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.push(AppRoutes.vehicles);
                  },
                  child: const Text('Ver todos'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  context.push(AppRoutes.vehicleRegister);
                },
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.primary,
                        size: 42,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'AÃºn no tienes vehÃ­culos registrados',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Registra tu primer vehÃ­culo para comenzar a gestionar su mantenimiento.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: () {
                context.push(AppRoutes.vehicleRegister);
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Registrar vehÃ­culo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 16),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
