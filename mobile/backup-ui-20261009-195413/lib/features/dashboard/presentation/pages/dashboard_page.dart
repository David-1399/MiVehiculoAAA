import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../vehicles/presentation/controllers/vehicles_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleState = ref.watch(vehiclesProvider);
    final vehicles = vehicleState.vehicles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MiVehiculoAAA'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesi\u00F3n',
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
              'Este es el resumen general de tus veh\u00EDculos.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.directions_car_outlined,
                    value: vehicles.length.toString(),
                    label: 'Veh\u00EDculos',
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
                    'Mis veh\u00EDculos',
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
            if (vehicles.isEmpty)
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
                          'A\u00FAn no tienes veh\u00EDculos registrados',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Registra tu primer veh\u00EDculo para comenzar a gestionar su mantenimiento.',
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
              )
            else
              ...vehicles
                  .take(3)
                  .map(
                    (vehicle) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.directions_car_rounded,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            vehicle.displayName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${vehicle.plate} \u00B7 ${vehicle.mileage} km',
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            ref
                                .read(vehiclesProvider.notifier)
                                .selectVehicle(vehicle.id);

                            context.push(AppRoutes.vehicleDetail);
                          },
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                context.push(AppRoutes.vehicleRegister);
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Registrar veh\u00EDculo'),
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
