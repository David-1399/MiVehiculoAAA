import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/catalogs/presentation/controllers/catalogs_provider.dart';
import '../../../../core/network/api_exception.dart';
import '../../../vehicles/presentation/controllers/vehicles_provider.dart';
import '../controllers/maintenance_provider.dart';

class MaintenanceDetailPage extends ConsumerWidget {
  const MaintenanceDetailPage({super.key});

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
    final maintenance = ref.watch(maintenanceProvider).selectedMaintenance;
    final vehicle = ref.watch(vehiclesProvider).selectedVehicle;
    final catalogs = ref.watch(catalogsProvider).asData?.value;

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

    final type = catalogs?.maintenanceTypeById(maintenance.maintenanceTypeId);
    final typeName = type?.name ?? 'Mantenimiento';
    final category = type?.attributes['category'] == 'corrective'
        ? 'Correctivo'
        : 'Preventivo';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver a mantenimientos',
          onPressed: () {
            context.go(AppRoutes.maintenance);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Detalle mantenimiento'),
        actions: [
          IconButton(
            tooltip: 'Editar mantenimiento',
            onPressed: () {
              context.push(AppRoutes.maintenanceEdit);
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Text(
                    typeName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Chip(label: Text(category)),
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
                    label: 'Vehículo',
                    value: vehicle?.displayName ?? 'Vehículo',
                  ),
                  const Divider(),
                  _InfoRow(label: 'Fecha', value: _date(maintenance.date)),
                  const Divider(),
                  _InfoRow(
                    label: 'Kilometraje',
                    value: '${maintenance.mileage} km',
                  ),
                  const Divider(),
                  _InfoRow(label: 'Costo', value: _money(maintenance.cost)),
                  const Divider(),
                  _InfoRow(
                    label: 'Taller',
                    value: maintenance.workshop ?? 'No registrado',
                  ),
                  if (maintenance.nextMileage != null) ...[
                    const Divider(),
                    _InfoRow(
                      label: 'Próximo kilometraje',
                      value: '${maintenance.nextMileage} km',
                    ),
                  ],
                  if (maintenance.nextDate != null) ...[
                    const Divider(),
                    _InfoRow(
                      label: 'Próxima fecha',
                      value: _date(maintenance.nextDate!),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Observaciones',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(maintenance.observations ?? 'Sin observaciones.'),
              ),
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: () {
              context.push(AppRoutes.maintenanceEdit);
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar mantenimiento'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              final confirmed =
                  await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: const Text('Eliminar mantenimiento'),
                        content: const Text(
                          'Esta acción eliminará el registro de mantenimiento. ¿Deseas continuar?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(false);
                            },
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(true);
                            },
                            child: const Text('Eliminar'),
                          ),
                        ],
                      );
                    },
                  ) ??
                  false;

              if (!confirmed || !context.mounted) {
                return;
              }

              try {
                await ref
                    .read(maintenanceProvider.notifier)
                    .deleteMaintenance(maintenance.id);

                if (!context.mounted) {
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mantenimiento eliminado correctamente.'),
                  ),
                );

                context.go(AppRoutes.maintenance);
              } on ApiException catch (error) {
                if (!context.mounted) {
                  return;
                }

                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(error.message)));
              }
            },
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
            ),
            label: const Text(
              'Eliminar mantenimiento',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
