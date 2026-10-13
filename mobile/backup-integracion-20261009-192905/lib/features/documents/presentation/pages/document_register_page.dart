import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';

class DocumentRegisterPage extends StatefulWidget {
  const DocumentRegisterPage({super.key});

  @override
  State<DocumentRegisterPage> createState() => _DocumentRegisterPageState();
}

class _DocumentRegisterPageState extends State<DocumentRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _numberController = TextEditingController();
  final _providerController = TextEditingController();

  String? _documentType;
  DateTime _issueDate = DateTime.now();
  DateTime? _expirationDate;

  final List<String> _documentTypes = const [
    'SOAT',
    'Revisión técnico-mecánica',
    'Seguro todo riesgo',
    'Tarjeta de propiedad',
    'Otro',
  ];

  @override
  void dispose() {
    _numberController.dispose();
    _providerController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> _selectIssueDate() async {
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

  Future<void> _selectExpirationDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (result != null) {
      setState(() {
        _expirationDate = result;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_expirationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la fecha de vencimiento.')),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Documento registrado correctamente.')),
    );

    context.go(AppRoutes.documents);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar documento')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Datos del documento',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Registra los documentos asociados al vehículo.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),

                DropdownButtonFormField<String>(
                  initialValue: _documentType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de documento',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  items: _documentTypes
                      .map(
                        (type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _documentType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecciona el tipo de documento';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _numberController,
                  decoration: const InputDecoration(
                    labelText: 'Número o referencia',
                    prefixIcon: Icon(Icons.numbers_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el número del documento';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _providerController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Entidad o aseguradora',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                ),

                const SizedBox(height: 16),

                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _selectIssueDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de expedición',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(_formatDate(_issueDate)),
                  ),
                ),

                const SizedBox(height: 16),

                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _selectExpirationDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de vencimiento',
                      prefixIcon: Icon(Icons.event_busy_outlined),
                    ),
                    child: Text(
                      _expirationDate == null
                          ? 'Seleccionar'
                          : _formatDate(_expirationDate!),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'La carga de archivos se habilitará posteriormente.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.attach_file_rounded),
                  label: const Text('Adjuntar documento'),
                ),

                const SizedBox(height: 16),

                FilledButton(
                  onPressed: _submit,
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
