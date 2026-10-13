import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/vehicles_provider.dart';

class VehicleRegisterPage extends ConsumerStatefulWidget {
  const VehicleRegisterPage({super.key});

  @override
  ConsumerState<VehicleRegisterPage> createState() {
    return _VehicleRegisterPageState();
  }
}

class _VehicleRegisterPageState extends ConsumerState<VehicleRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();
  final _mileageController = TextEditingController();

  String? _vehicleType;

  final List<String> _vehicleTypes = const [
    'Motocicleta',
    'Autom\u00F3vil',
    'Camioneta',
    'Van',
    'Cami\u00F3n',
    'Bus',
    'Otro',
  ];

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ref
        .read(vehiclesProvider.notifier)
        .addVehicle(
          type: _vehicleType!,
          brand: _brandController.text,
          model: _modelController.text,
          year: int.parse(_yearController.text),
          plate: _plateController.text,
          mileage: int.parse(_mileageController.text),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veh\u00EDculo registrado correctamente.')),
    );

    context.go(AppRoutes.vehicleDetail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Cancelar',
          onPressed: () {
            context.go(AppRoutes.vehicles);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Registrar veh\u00EDculo'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Datos del veh\u00EDculo',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ingresa la informaci\u00F3n principal del veh\u00EDculo.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  initialValue: _vehicleType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de veh\u00EDculo',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _vehicleTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _vehicleType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecciona el tipo de veh\u00EDculo';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _brandController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Marca',
                    prefixIcon: Icon(Icons.factory_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa la marca';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _modelController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Modelo',
                    prefixIcon: Icon(Icons.directions_car_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el modelo';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'A\u00F1o',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  validator: (value) {
                    final year = int.tryParse(value ?? '');

                    if (year == null || year < 1900 || year > 2100) {
                      return 'Ingresa un a\u00F1o v\u00E1lido';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _plateController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Placa',
                    prefixIcon: Icon(Icons.pin_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 5) {
                      return 'Ingresa una placa v\u00E1lida';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mileageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Kilometraje actual',
                    suffixText: 'km',
                    prefixIcon: Icon(Icons.speed_rounded),
                  ),
                  validator: (value) {
                    final mileage = int.tryParse(value ?? '');

                    if (mileage == null || mileage < 0) {
                      return 'Ingresa un kilometraje v\u00E1lido';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'La c\u00E1mara se habilitar\u00E1 posteriormente.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Agregar fotograf\u00EDa'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _submit,
                  child: const Text('Guardar veh\u00EDculo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
