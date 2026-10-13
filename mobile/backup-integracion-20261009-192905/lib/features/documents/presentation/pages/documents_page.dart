import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Toyota Corolla',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'ABC123',
              style: TextStyle(color: AppColors.textSecondary),
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
              title: 'Revisión técnico-mecánica',
              subtitle: 'Certificado de revisión',
              expiration: 'Vence: 15 Nov 2026',
              status: 'Próximo',
              statusColor: AppColors.warning,
              icon: Icons.fact_check_outlined,
            ),

            const SizedBox(height: 12),

            const _DocumentCard(
              title: 'Seguro todo riesgo',
              subtitle: 'Póliza voluntaria',
              expiration: 'Vence: 10 Mar 2027',
              status: 'Vigente',
              statusColor: AppColors.success,
              icon: Icons.shield_outlined,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(expiration, style: const TextStyle(fontSize: 13)),
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
