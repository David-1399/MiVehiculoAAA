import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/catalogs/presentation/controllers/catalogs_provider.dart';
import '../../../../core/widgets/evidence_image_preview.dart';
import '../../domain/entities/vehicle_document.dart';
import '../controllers/documents_provider.dart';

class DocumentDetailPage extends ConsumerWidget {
  const DocumentDetailPage({super.key});

  String _date(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');

    return '$day/$month/${value.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final document = ref.watch(documentsProvider).selectedDocument;
    final catalogs = ref.watch(catalogsProvider).asData?.value;

    if (document == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle del documento')),
        body: Center(
          child: FilledButton(
            onPressed: () {
              context.go(AppRoutes.documents);
            },
            child: const Text('Volver a documentos'),
          ),
        ),
      );
    }

    final type =
        catalogs?.documentTypeById(document.documentTypeId)?.name ??
        'Tipo no disponible';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.go(AppRoutes.documents);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Detalle del documento'),
        actions: [
          IconButton(
            tooltip: 'Editar',
            onPressed: () {
              context.push(AppRoutes.documentEdit);
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _InfoCard(
            icon: Icons.description_outlined,
            title: type,
            children: [
              _Row(label: 'Número', value: document.number),
              _Row(label: 'Expedición', value: _date(document.issueDate)),
              _Row(
                label: 'Vencimiento',
                value: document.expirationDate == null
                    ? 'Sin vencimiento'
                    : _date(document.expirationDate!),
              ),
              _Row(
                label: 'Estado',
                value: document.statusAt(DateTime.now()).label,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Evidencia fotográfica',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          if (document.evidencePath == null)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.no_photography_outlined,
                      color: AppColors.textSecondary,
                      size: 36,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Este documento no tiene una fotografía adjunta.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            EvidenceImagePreview(path: document.evidencePath!),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () {
              context.push(AppRoutes.documentEdit);
            },
            icon: const Icon(Icons.edit_outlined),
            label: Text(
              document.evidencePath == null
                  ? 'Editar y agregar fotografía'
                  : 'Editar documento',
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 26),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
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
