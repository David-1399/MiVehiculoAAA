import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/catalogs/presentation/controllers/catalogs_provider.dart';
import '../../../vehicles/presentation/controllers/vehicles_provider.dart';
import '../controllers/documents_provider.dart';

class DocumentRegisterPage extends ConsumerStatefulWidget {
  const DocumentRegisterPage({super.key});

  @override
  ConsumerState<DocumentRegisterPage> createState() {
    return _DocumentRegisterPageState();
  }
}

class _DocumentRegisterPageState extends ConsumerState<DocumentRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _numberController = TextEditingController();

  String? _documentTypeId;

  DateTime _issueDate = DateTime.now();

  DateTime? _expirationDate;

  bool _hasExpiration = true;

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  String _date(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');

    final month = value.month.toString().padLeft(2, '0');

    return '$day/$month/${value.year}';
  }

  Future<void> _pickIssueDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _issueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (result != null) {
      setState(() {
        _issueDate = result;

        if (_expirationDate != null && _expirationDate!.isBefore(result)) {
          _expirationDate = null;
        }
      });
    }
  }

  Future<void> _pickExpirationDate() async {
    final initial =
        _expirationDate ?? _issueDate.add(const Duration(days: 365));

    final result = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _issueDate,
      lastDate: DateTime(2100),
    );

    if (result != null) {
      setState(() {
        _expirationDate = result;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vehicle = ref.read(vehiclesProvider).selectedVehicle;

    if (vehicle == null) {
      return;
    }

    if (_hasExpiration && _expirationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la fecha de vencimiento.')),
      );
      return;
    }

    await ref
        .read(documentsProvider.notifier)
        .addDocument(
          vehicleId: vehicle.id,
          documentTypeId: _documentTypeId!,
          number: _numberController.text,
          issueDate: _issueDate,
          expirationDate: _hasExpiration ? _expirationDate : null,
        );

    if (!mounted) {
      return;
    }

    context.go(AppRoutes.documents);
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = ref.watch(vehiclesProvider).selectedVehicle;

    final catalogsAsync = ref.watch(catalogsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            context.go(AppRoutes.documents);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Registrar documento',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 31, vertical: 22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _FieldLabel('Vehículo'),
                _StaticField(
                  value: vehicle == null
                      ? 'Vehículo no seleccionado'
                      : '${vehicle.displayName} (${vehicle.plate})',
                ),

                const SizedBox(height: 10),

                const _FieldLabel('Tipo de documento'),

                catalogsAsync.when(
                  data: (catalogs) {
                    return DropdownButtonFormField<String>(
                      initialValue: _documentTypeId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        hintText: 'Seleccionar tipo',
                      ),
                      items: catalogs.activeDocumentTypes
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _documentTypeId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecciona el tipo de documento';
                        }
                        return null;
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => const Text(
                    'No fue posible cargar los tipos de documento.',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),

                const SizedBox(height: 10),

                const _FieldLabel('Número'),
                TextFormField(
                  controller: _numberController,
                  decoration: const InputDecoration(
                    hintText: 'Número del documento',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el número';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 10),

                const _FieldLabel('Fecha de expedición'),
                _DateField(value: _date(_issueDate), onTap: _pickIssueDate),

                const SizedBox(height: 12),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Tiene fecha de vencimiento',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  value: _hasExpiration,
                  onChanged: (value) {
                    setState(() {
                      _hasExpiration = value;

                      if (!value) {
                        _expirationDate = null;
                      }
                    });
                  },
                ),

                if (_hasExpiration) ...[
                  const SizedBox(height: 4),
                  const _FieldLabel('Fecha de vencimiento'),
                  _DateField(
                    value: _expirationDate == null
                        ? 'Seleccionar'
                        : _date(_expirationDate!),
                    onTap: _pickExpirationDate,
                  ),
                ],

                const SizedBox(height: 26),

                const _FieldLabel('Archivo o fotografía'),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: AppColors.secondary,
                        size: 30,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'La captura de evidencia se habilitará con el módulo de cámara.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                FilledButton(
                  onPressed: vehicle != null && catalogsAsync.hasValue
                      ? _submit
                      : null,
                  child: const Text('Guardar documento'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _StaticField extends StatelessWidget {
  const _StaticField({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          value,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
