import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/catalogs/presentation/controllers/catalogs_provider.dart';
import '../controllers/vehicles_provider.dart';

class VehicleDetailPage extends ConsumerWidget {
  const VehicleDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vehiclesProvider);
    final catalogs = ref.watch(catalogsProvider).asData?.value;
    final vehicle = state.selectedVehicle;

    if (vehicle == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              context.go(AppRoutes.vehicles);
            },
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text('Detalle del veh\u00EDculo'),
        ),
        body: Center(
          child: FilledButton(
            onPressed: () {
              context.go(AppRoutes.vehicles);
            },
            child: const Text('Volver a mis veh\u00EDculos'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver a mis veh\u00EDculos',
          onPressed: () {
            context.go(AppRoutes.vehicles);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Detalle del veh\u00EDculo'),
        actions: [
          IconButton(
            tooltip: 'Editar veh\u00EDculo',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'La edici\u00F3n se implementar\u00E1 en el siguiente incremento.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.directions_car_filled_rounded,
                        size: 44,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      vehicle.displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle.plate,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Activo',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow(
                      label: 'Tipo',
                      value:
                          catalogs
                              ?.vehicleTypeById(vehicle.vehicleTypeId)
                              ?.name ??
                          'Tipo no disponible',
                    ),
                    const Divider(),
                    _InfoRow(label: 'Marca', value: vehicle.brand),
                    const Divider(),
                    _InfoRow(label: 'Modelo', value: vehicle.model),
                    const Divider(),
                    _InfoRow(label: 'A\u00F1o', value: vehicle.year.toString()),
                    const Divider(),
                    _InfoRow(
                      label: 'Kilometraje',
                      value: '${vehicle.mileage} km',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Gesti\u00F3n del veh\u00EDculo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _ModuleTile(
              icon: Icons.build_outlined,
              title: 'Mantenimientos',
              subtitle: 'Historial y pr\u00F3ximos servicios',
              onTap: () {
                context.push(AppRoutes.maintenance);
              },
            ),
            const SizedBox(height: 10),
            _ModuleTile(
              icon: Icons.speed_outlined,
              title: 'Kilometraje',
              subtitle: 'Lecturas e historial',
              onTap: () {
                context.push(AppRoutes.mileage);
              },
            ),
            const SizedBox(height: 10),
            _ModuleTile(
              icon: Icons.description_outlined,
              title: 'Documentos',
              subtitle: 'SOAT, tecnomec\u00E1nica y seguros',
              onTap: () {
                context.push(AppRoutes.documents);
              },
            ),
            const SizedBox(height: 10),
            _ModuleTile(
              icon: Icons.payments_outlined,
              title: 'Gastos',
              subtitle: 'Costos asociados al veh\u00EDculo',
              onTap: () {
                context.push(AppRoutes.expenses);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
