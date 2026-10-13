import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/vehicles_provider.dart';

class VehiclesPage extends ConsumerWidget {
  const VehiclesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vehiclesProvider);
    final vehicles = state.vehicles;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver al inicio',
          onPressed: () {
            context.go(AppRoutes.dashboard);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Mis veh\u00EDculos'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.vehicleRegister);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Veh\u00EDculos registrados',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Consulta y administra los veh\u00EDculos asociados a tu cuenta.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: vehicles.isEmpty
                  ? Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.directions_car_outlined,
                                size: 56,
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No tienes veh\u00EDculos registrados',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Agrega tu primer veh\u00EDculo para comenzar.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 20),
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
                      ),
                    )
                  : ListView.separated(
                      itemCount: vehicles.length,
                      separatorBuilder: (_, _) {
                        return const SizedBox(height: 10);
                      },
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];

                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(14),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.directions_car_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                            title: Text(
                              vehicle.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              '${vehicle.plate}\n${vehicle.mileage} km',
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              ref
                                  .read(vehiclesProvider.notifier)
                                  .selectVehicle(vehicle.id);

                              context.push(AppRoutes.vehicleDetail);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
