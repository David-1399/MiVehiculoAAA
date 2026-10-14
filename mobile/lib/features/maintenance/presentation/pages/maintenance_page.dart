import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/catalogs/presentation/controllers/catalogs_provider.dart';
import '../../../vehicles/presentation/controllers/vehicles_provider.dart';
import '../controllers/maintenance_provider.dart';

class MaintenancePage extends ConsumerWidget {
  const MaintenancePage({super.key});

  String _money(int value) {
    final text = value.toString();
    final result = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        result.write('.');
      }

      result.write(text[i]);
    }

    return '\$${result.toString()}';
  }

  String _date(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');

    final month = value.month.toString().padLeft(2, '0');

    return '$day/$month/${value.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicle = ref.watch(vehiclesProvider).selectedVehicle;

    final maintenanceState = ref.watch(maintenanceProvider);

    final catalogsAsync = ref.watch(catalogsProvider);

    if (vehicle == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mantenimientos')),
        body: Center(
          child: FilledButton(
            onPressed: () {
              context.go(AppRoutes.vehicles);
            },
            child: const Text('Seleccionar vehículo'),
          ),
        ),
      );
    }

    return catalogsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Mantenimientos')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: const Text('Mantenimientos')),
        body: const Center(child: Text('No fue posible cargar los catálogos.')),
      ),
      data: (catalogs) {
        final allVehicleItems = maintenanceState.items
            .where((item) => item.vehicleId == vehicle.id)
            .toList();

        final filteredItems = maintenanceState.forVehicle(vehicle.id, catalogs);

        final preventiveCount = allVehicleItems.where((item) {
          return catalogs
                  .maintenanceTypeById(item.maintenanceTypeId)
                  ?.attributes['category'] ==
              'preventive';
        }).length;

        final correctiveCount = allVehicleItems.where((item) {
          return catalogs
                  .maintenanceTypeById(item.maintenanceTypeId)
                  ?.attributes['category'] ==
              'corrective';
        }).length;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Volver al vehículo',
              onPressed: () {
                context.go(AppRoutes.vehicleDetail);
              },
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: const Text('Mantenimientos'),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            onPressed: () {
              context.push(AppRoutes.maintenanceRegister);
            },
            child: const Icon(Icons.add_rounded),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                vehicle.displayName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${vehicle.plate} · ${vehicle.mileage} km',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      value: preventiveCount.toString(),
                      label: 'Preventivos',
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      value: correctiveCount.toString(),
                      label: 'Correctivos',
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: MaintenanceFilter.values.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(filter.label),
                        selected: maintenanceState.filter == filter,
                        onSelected: (_) {
                          ref
                              .read(maintenanceProvider.notifier)
                              .setFilter(filter);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Historial',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      context.push(AppRoutes.maintenanceRegister);
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Registrar'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (filteredItems.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.build_circle_outlined,
                          size: 44,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No hay mantenimientos registrados.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...filteredItems.map((maintenance) {
                  final type = catalogs.maintenanceTypeById(
                    maintenance.maintenanceTypeId,
                  );

                  final category = type?.attributes['category'];

                  final categoryLabel = category == 'preventive'
                      ? 'Preventivo'
                      : category == 'corrective'
                      ? 'Correctivo'
                      : 'Sin clasificación';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.build_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          type?.name ?? 'Tipo no disponible',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '$categoryLabel · ${_date(maintenance.date)}\n'
                          '${maintenance.mileage} km · ${_money(maintenance.cost)}',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          ref
                              .read(maintenanceProvider.notifier)
                              .selectMaintenance(maintenance.id);

                          context.push(AppRoutes.maintenanceDetail);
                        },
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
