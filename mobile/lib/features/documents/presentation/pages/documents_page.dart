import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../vehicles/presentation/controllers/vehicles_provider.dart';

class DocumentsPage extends ConsumerWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicle = ref.watch(vehiclesProvider).selectedVehicle;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver al veh\u00EDculo',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              vehicle?.displayName ?? 'Veh\u00EDculo',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              vehicle?.plate ?? '',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            const _DocumentCard(
              title: 'SOAT',
              subtitle: 'Seguro obligatorio',
              expiration: 'Vence: 20 Dic 2026',
              status: 'Vigente',
              statusColor: AppColors.success,
              icon: Icons.health_and_safety_outlined,
            ),
            const SizedBox(height: 12),
            const _DocumentCard(
              title: 'Revisi\u00F3n t\u00E9cnico-mec\u00E1nica',
              subtitle: 'Certificado de revisi\u00F3n',
              expiration: 'Vence: 15 Nov 2026',
              status: 'Pr\u00F3ximo',
              statusColor: AppColors.warning,
              icon: Icons.fact_check_outlined,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.push(AppRoutes.documentRegister);
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Registrar documento'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.title,
    required this.subtitle,
    required this.expiration,
    required this.status,
    required this.statusColor,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String expiration;
  final String status;
  final Color statusColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
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
              child: Icon(icon, color: AppColors.primary),
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
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(expiration),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
