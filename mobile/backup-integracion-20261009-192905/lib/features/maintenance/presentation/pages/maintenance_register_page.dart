import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';

class MaintenanceRegisterPage extends StatefulWidget {
  const MaintenanceRegisterPage({super.key});

  @override
  State<MaintenanceRegisterPage> createState() =>
      _MaintenanceRegisterPageState();
}

class _MaintenanceRegisterPageState extends State<MaintenanceRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _mileageController = TextEditingController();
  final _costController = TextEditingController();
  final _workshopController = TextEditingController();
  final _observationsController = TextEditingController();

  String? _maintenanceType;
  DateTime _selectedDate = DateTime.now();

  final List<String> _maintenanceTypes = const [
    'Cambio de aceite',
    'Sistema de frenos',
    'Llantas',
    'Suspensión',
    'Sistema eléctrico',
    'Motor',
    'Alineación y balanceo',
    'Otro',
  ];

  @override
  void dispose() {
    _mileageController.dispose();
    _costController.dispose();
    _workshopController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  String get _formattedDate {
    final day = _selectedDate.day.toString().padLeft(2, '0');
    final month = _selectedDate.month.toString().padLeft(2, '0');
    final year = _selectedDate.year;

    return '$day/$month/$year';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mantenimiento registrado correctamente.')),
    );

    context.go(AppRoutes.maintenanceDetail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar mantenimiento')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Nuevo mantenimiento',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Registra el mantenimiento realizado al vehículo.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),

                DropdownButtonFormField<String>(
                  initialValue: _maintenanceType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de mantenimiento',
                    prefixIcon: Icon(Icons.build_outlined),
                  ),
                  items: _maintenanceTypes
                      .map(
                        (type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _maintenanceType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecciona un tipo de mantenimiento';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(_formattedDate),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _mileageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Kilometraje',
                    suffixText: 'km',
                    prefixIcon: Icon(Icons.speed_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa el kilometraje';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Costo',
                    prefixText: r'$ ',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa el costo';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _workshopController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Taller o proveedor',
                    prefixIcon: Icon(Icons.store_outlined),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _observationsController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 64),
                      child: Icon(Icons.notes_rounded),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'La captura de evidencias se habilitará posteriormente.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Agregar evidencia fotográfica'),
                ),

                const SizedBox(height: 16),

                FilledButton(
                  onPressed: _submit,
                  child: const Text('Guardar mantenimiento'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
