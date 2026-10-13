import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../vehicles/presentation/controllers/vehicles_provider.dart';

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

  String? _documentType;
  DateTime _issueDate = DateTime.now();
  DateTime? _expirationDate;

  final _documentTypes = const [
    'SOAT',
    'Revisi\u00F3n t\u00E9cnico-mec\u00E1nica',
    'Seguro todo riesgo',
    'Tarjeta de propiedad',
    'Otro',
  ];

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
      });
    }
  }

  Future<void> _pickExpirationDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate:
          _expirationDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (result != null) {
      setState(() {
        _expirationDate = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = ref.watch(vehiclesProvider).selectedVehicle;

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
                const _FieldLabel('Veh\u00EDculo'),
                _StaticField(
                  value: vehicle == null
                      ? 'Veh\u00EDculo no seleccionado'
                      : '${vehicle.displayName} (${vehicle.plate})',
                ),
                const SizedBox(height: 10),
                const _FieldLabel('Tipo de documento'),
                DropdownButtonFormField<String>(
                  initialValue: _documentType,
                  isExpanded: true,
                  decoration: const InputDecoration(),
                  hint: const Text('Seleccionar'),
                  selectedItemBuilder: (context) {
                    return _documentTypes.map((item) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList();
                  },
                  items: _documentTypes.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _documentType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecciona el tipo';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 10),
                const _FieldLabel('N\u00FAmero'),
                TextFormField(
                  controller: _numberController,
                  decoration: const InputDecoration(hintText: 'SOAT-2026-001'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el n\u00FAmero';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 10),
                const _FieldLabel('Fecha de expedici\u00F3n'),
                _DateField(value: _date(_issueDate), onTap: _pickIssueDate),
                const SizedBox(height: 10),
                const _FieldLabel('Fecha de vencimiento'),
                _DateField(
                  value: _expirationDate == null
                      ? 'Seleccionar'
                      : _date(_expirationDate!),
                  onTap: _pickExpirationDate,
                ),
                const SizedBox(height: 26),
                const _FieldLabel('Archivo o fotograf\u00EDa'),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {},
                  child: Container(
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
                          'Adjuntar evidencia',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                FilledButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    if (_expirationDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selecciona la fecha de vencimiento.'),
                        ),
                      );

                      return;
                    }

                    context.go(AppRoutes.documents);
                  },
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
