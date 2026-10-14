import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/catalogs/presentation/controllers/catalogs_provider.dart';
import '../../../vehicles/presentation/controllers/vehicles_provider.dart';
import '../controllers/maintenance_provider.dart';

class MaintenanceDetailPage extends ConsumerWidget {
  const MaintenanceDetailPage({super.key});

  String _date(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');

    final month = value.month.toString().padLeft(2, '0');

    return '$day/$month/${value.year}';
  }

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenance = ref.watch(maintenanceProvider).selectedMaintenance;

    final vehicle = ref.watch(vehiclesProvider).selectedVehicle;

    final catalogsAsync = ref.watch(catalogsProvider);

    if (maintenance == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle mantenimiento')),
        body: Center(
          child: FilledButton(
            onPressed: () {
              context.go(AppRoutes.maintenance);
            },
            child: const Text('Volver a mantenimientos'),
          ),
        ),
      );
    }

    return catalogsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Detalle mantenimiento')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: const Text('Detalle mantenimiento')),
        body: const Center(child: Text('No fue posible cargar los catálogos.')),
      ),
      data: (catalogs) {
        final type = catalogs.maintenanceTypeById(
          maintenance.maintenanceTypeId,
        );

        final category = type?.attributes['category'];

        final categoryLabel = category == 'preventive'
            ? 'Preventivo'
            : category == 'corrective'
            ? 'Correctivo'
            : 'Sin clasificación';

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                context.go(AppRoutes.maintenance);
              },
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: const Text('Detalle mantenimiento'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.build_circle_outlined,
                          color: AppColors.primary,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        type?.name ?? 'Tipo no disponible',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(label: Text(categoryLabel)),
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
                      if (vehicle != null)
                        _DetailRow(
                          label: 'Vehículo',
                          value: vehicle.displayName,
                        ),
                      if (vehicle != null) const Divider(),

                      _DetailRow(
                        label: 'Fecha',
                        value: _date(maintenance.date),
                      ),
                      const Divider(),

                      _DetailRow(
                        label: 'Kilometraje',
                        value: '${maintenance.mileage} km',
                      ),
                      const Divider(),

                      _DetailRow(
                        label: 'Costo',
                        value: _money(maintenance.cost),
                      ),

                      if (maintenance.workshop != null) ...[
                        const Divider(),
                        _DetailRow(
                          label: 'Taller',
                          value: maintenance.workshop!,
                        ),
                      ],

                      if (maintenance.nextMileage != null) ...[
                        const Divider(),
                        _DetailRow(
                          label: 'Próximo kilometraje',
                          value: '${maintenance.nextMileage} km',
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              if (maintenance.observations != null) ...[
                const SizedBox(height: 20),
                const Text(
                  'Observaciones',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(maintenance.observations!),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
