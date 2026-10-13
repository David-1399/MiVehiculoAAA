import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';

class MaintenanceDetailPage extends StatelessWidget {
  const MaintenanceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.go(AppRoutes.maintenance);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Detalle mantenimiento'),
        actions: [
          IconButton(
            tooltip: 'Editar',
            onPressed: () {},
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
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.build_circle_outlined,
                        color: AppColors.success,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Cambio de aceite',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                        'Realizado',
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

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _DetailRow(label: 'Vehículo', value: 'Toyota Corolla'),
                    Divider(),
                    _DetailRow(label: 'Placa', value: 'ABC123'),
                    Divider(),
                    _DetailRow(label: 'Fecha', value: '20/09/2026'),
                    Divider(),
                    _DetailRow(label: 'Kilometraje', value: '35.000 km'),
                    Divider(),
                    _DetailRow(label: 'Costo', value: r'$180.000'),
                    Divider(),
                    _DetailRow(label: 'Taller', value: 'Taller Central'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Observaciones',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 8),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Cambio de aceite de motor y filtro. Se realizó inspección general del vehículo sin novedades adicionales.',
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text('Evidencias', style: Theme.of(context).textTheme.titleMedium),

            const SizedBox(height: 8),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.textSecondary,
                      size: 38,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No hay evidencias adjuntas',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Agregar evidencia'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
