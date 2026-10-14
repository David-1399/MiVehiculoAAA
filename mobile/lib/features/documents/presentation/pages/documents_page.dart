import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/catalogs/presentation/controllers/catalogs_provider.dart';
import '../../../vehicles/presentation/controllers/vehicles_provider.dart';
import '../../domain/entities/vehicle_document.dart';
import '../controllers/documents_provider.dart';

class DocumentsPage extends ConsumerWidget {
  const DocumentsPage({super.key});

  String _date(DateTime value) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    return '${value.day} ${months[value.month - 1]} ${value.year}';
  }

  Color _statusColor(VehicleDocumentStatus status) {
    switch (status) {
      case VehicleDocumentStatus.valid:
        return AppColors.success;
      case VehicleDocumentStatus.expiringSoon:
        return AppColors.warning;
      case VehicleDocumentStatus.expired:
        return AppColors.error;
      case VehicleDocumentStatus.noExpiration:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicle = ref.watch(vehiclesProvider).selectedVehicle;
    final documentsState = ref.watch(documentsProvider);
    final catalogs = ref.watch(catalogsProvider).asData?.value;

    if (vehicle == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Documentos')),
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

    final documents = documentsState.forVehicle(vehicle.id);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver al vehículo',
          onPressed: () {
            context.go(AppRoutes.vehicleDetail);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Documentos'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          context.push(AppRoutes.documentRegister);
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
            vehicle.plate,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          if (documents.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 44,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No hay documentos registrados.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Registra los documentos asociados a este vehículo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ...documents.map((document) {
              final status = document.statusAt(DateTime.now());
              final color = _statusColor(status);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      ref
                          .read(documentsProvider.notifier)
                          .selectDocument(document.id);

                      context.push(AppRoutes.documentDetail);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  catalogs
                                          ?.documentTypeById(
                                            document.documentTypeId,
                                          )
                                          ?.name ??
                                      'Tipo no disponible',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  document.number,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  document.expirationDate == null
                                      ? 'Sin fecha de vencimiento'
                                      : 'Vence: ${_date(document.expirationDate!)}',
                                ),
                                if (document.evidencePath != null) ...[
                                  const SizedBox(height: 6),
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.photo_camera_outlined,
                                        size: 16,
                                        color: AppColors.secondary,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Con evidencia fotográfica',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              status.label,
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              context.push(AppRoutes.documentRegister);
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Registrar documento'),
          ),
        ],
      ),
    );
  }
}
